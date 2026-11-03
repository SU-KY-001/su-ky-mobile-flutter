import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../../core/auth/signed_in.dart';
import '../../core/error/app_exception.dart';
import '../../core/error/result.dart';
import '../../core/logging/app_logger.dart';
import '../../core/platform/notification_permission.dart';
import '../catalog/data/catalog_providers.dart';
import '../catalog/domain/episode.dart';
import '../catalog/domain/episode_detail.dart';
import 'audio_defaults.dart';
import 'data/playback_repository.dart';
import 'domain/playback_info.dart';
import 'local_playback_store.dart';
import 'playback_providers.dart';
import 'playback_state.dart';

part 'playback_controller_lifecycle.dart';
part 'playback_controller_loading.dart';

/// A guest's Play request, replayed once they sign in (within a TTL).
final class _PendingPlay {
  _PendingPlay(this.slug, this.narrationId) : requestedAt = DateTime.now();

  final String slug;
  final String? narrationId;
  final DateTime requestedAt;
}

/// The only owner of the [AudioPlayer]. Not autoDispose: the mini-player and
/// background playback outlive every screen.
class PlaybackController extends Notifier<PlaybackState> {
  int _loadToken = 0;
  Timer? _sleepTimer;
  _PendingPlay? _pending;
  bool _askedNotifications = false;
  DateTime _lastSave = DateTime.fromMillisecondsSinceEpoch(0);

  AudioPlayer get _player => ref.read(audioPlayerProvider);
  LocalPlaybackStore get _store => ref.read(localPlaybackStoreProvider);

  /// Accessors for this library's part files: Riverpod marks `state` and
  /// `ref` protected, so top-level helpers cannot read them directly.
  PlaybackState get playbackState => state;
  void updatePlaybackState(PlaybackState value) => state = value;
  Ref get providerRef => ref;

  @override
  PlaybackState build() {
    final player = ref.watch(audioPlayerProvider);
    final subscriptions = [
      player.playerStateStream.listen((it) => _onPlayerState(this, it)),
      player.positionStream.listen((it) => _onPosition(this, it)),
    ];
    ref.listen(
      signedInProvider,
      (previous, signedIn) => _onSignedInChanged(this, previous, signedIn),
    );
    ref.onDispose(() {
      _sleepTimer?.cancel();
      for (final subscription in subscriptions) {
        subscription.cancel();
      }
    });
    return const PlaybackState();
  }

  /// Plays [slug]. A guest gets [PlayOutcome.needsLogin] and the request is
  /// kept so it can resume after sign-in.
  Future<PlayOutcome> playEpisode(String slug, {String? narrationId}) async {
    if (!ref.read(signedInProvider)) {
      _pending = _PendingPlay(slug, narrationId);
      return PlayOutcome.needsLogin;
    }
    _pending = null;
    state = state.copyWith(
      request: PlayRequest(slug: slug, narrationId: narrationId),
    );
    if (_isLoaded(slug, narrationId)) {
      await _resume();
      return PlayOutcome.started;
    }
    final token = ++_loadToken;
    state = state.copyWith(
      status: PlaybackStatus.loading,
      playing: false,
      clearError: true,
    );
    await _player.pause();
    await _persistPosition(this);
    final EpisodeDetail detail;
    try {
      detail = await ref.read(episodeDetailProvider(slug).future);
    } on AppException catch (error) {
      return _fail(token, _errorFor(error));
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'Episode load failed: $slug',
        error: error,
        stackTrace: stackTrace,
      );
      return _fail(token, PlaybackError.network);
    }
    final narration = detail.playableFor(narrationId);
    state = state.copyWith(episode: detail);
    if (narration == null) return _fail(token, PlaybackError.unavailable);
    final result = await _openPlayback(
      this,
      detail,
      narration,
      token,
      autoplay: true,
    );
    return _settle(token, result);
  }

  /// Switches to another narration of the loaded episode, keeping the
  /// listening position (clamped to the new audio's length).
  Future<void> switchNarration(String narrationId) async {
    final detail = state.episode;
    if (detail == null || narrationId == state.narrationId) return;
    final target = detail.availableNarrations
        .where((n) => n.id == narrationId)
        .firstOrNull;
    if (target == null) return;
    final token = ++_loadToken;
    final position = _player.position;
    final wasPlaying = state.playing;
    await _persistPosition(this);
    state = state.copyWith(status: PlaybackStatus.loading, clearError: true);
    final result = await _openPlayback(
      this,
      detail,
      target,
      token,
      autoplay: wasPlaying,
      startAt: position,
    );
    _settle(token, result);
  }

  Future<void> togglePlayPause() async {
    final request = state.request;
    if (state.status == PlaybackStatus.error && request != null) {
      await playEpisode(request.slug, narrationId: request.narrationId);
      return;
    }
    if (state.status != PlaybackStatus.ready) return;
    if (state.playing) {
      await pause();
    } else {
      await _resume();
    }
  }

  Future<void> pause() async {
    await _player.pause();
    await _persistPosition(this);
  }

  Future<void> restart() async {
    if (state.status != PlaybackStatus.ready) return;
    await _player.seek(Duration.zero);
    await _resume();
  }

  Future<void> seekToRatio(double ratio) async {
    if (state.status != PlaybackStatus.ready || state.durationMs <= 0) return;
    final millis = (state.durationMs * ratio.clamp(0.0, 1.0)).round();
    await _player.seek(Duration(milliseconds: millis));
  }

  Future<void> skip(int seconds) async {
    if (state.status != PlaybackStatus.ready) return;
    final target = _player.position + Duration(seconds: seconds);
    final millis = target.inMilliseconds.clamp(0, state.durationMs);
    await _player.seek(Duration(milliseconds: millis));
  }

  Future<void> cycleSpeed() async {
    const speeds = AudioDefaults.playbackSpeeds;
    final next = speeds[(speeds.indexOf(state.speed) + 1) % speeds.length];
    await _player.setSpeed(next);
    state = state.copyWith(speed: next);
  }

  void toggleSleepTimer() {
    _sleepTimer?.cancel();
    final enabled = !state.sleepEnabled;
    state = state.copyWith(sleepEnabled: enabled);
    if (!enabled) return;
    _sleepTimer = Timer(
      const Duration(minutes: AudioDefaults.sleepTimerMinutes),
      () {
        state = state.copyWith(sleepEnabled: false);
        unawaited(pause());
      },
    );
  }

  bool _isLoaded(String slug, String? narrationId) =>
      state.status == PlaybackStatus.ready &&
      state.episode?.slug == slug &&
      (narrationId == null || narrationId == state.narrationId);

  Future<void> _resume() async {
    if (state.completed) {
      await _player.seek(Duration.zero);
      state = state.copyWith(completed: false);
    }
    unawaited(_player.play());
  }

  PlayOutcome _fail(int token, PlaybackError error) {
    if (token == _loadToken) {
      // Never leave the previous episode's audio playing under an error.
      unawaited(_player.stop());
      state = state.copyWith(
        status: PlaybackStatus.error,
        error: error,
        playing: false,
      );
    }
    return PlayOutcome.failed;
  }

  /// Forgets a guest's Play request (they dismissed the sign-in prompt).
  void cancelPendingPlay() => _pending = null;

  PlayOutcome _settle(int token, _OpenResult result) => switch (result) {
    _OpenResult.opened => PlayOutcome.started,
    _OpenResult.superseded => PlayOutcome.started,
    _OpenResult.unavailable => _fail(token, PlaybackError.unavailable),
    _OpenResult.network => _fail(token, PlaybackError.network),
    _OpenResult.player => _fail(token, PlaybackError.player),
  };
}

final playbackControllerProvider =
    NotifierProvider<PlaybackController, PlaybackState>(PlaybackController.new);
