part of 'playback_controller.dart';

const _maxOpenAttempts = 2;
const _notFoundStatus = 404;
const _millisPerSecond = 1000;

enum _OpenResult { opened, superseded, unavailable, network, player }

Future<_OpenResult> _openPlayback(
  PlaybackController c,
  EpisodeDetail detail,
  Narration narration,
  int token, {
  required bool autoplay,
  Duration? startAt,
}) async {
  for (var attempt = 1; attempt <= _maxOpenAttempts; attempt++) {
    final result = await c.providerRef
        .read(playbackRepositoryProvider)
        .playback(narration.id);
    if (token != c._loadToken) return _OpenResult.superseded;
    final PlaybackInfo info;
    switch (result) {
      case Err(:final error):
        return _errorFor(error) == PlaybackError.unavailable
            ? _OpenResult.unavailable
            : _OpenResult.network;
      case Ok(:final value):
        info = value;
    }
    try {
      await c._player
          .setAudioSource(
            AudioSource.uri(info.url, tag: _mediaItem(detail, info)),
            initialPosition: _startPosition(c, info, startAt),
          )
          .timeout(AudioDefaults.loadTimeout);
    } on PlayerInterruptedException {
      return _OpenResult.superseded;
    } on Object catch (error, stackTrace) {
      // A signed URL may have expired: fetch a fresh one once.
      AppLogger.error(
        'Cannot open narration ${narration.id} (attempt $attempt)',
        error: error,
        stackTrace: stackTrace,
      );
      if (attempt == _maxOpenAttempts) {
        return error is TimeoutException
            ? _OpenResult.network
            : _OpenResult.player;
      }
      continue;
    }
    if (token != c._loadToken) return _OpenResult.superseded;
    await _onOpened(c, detail, narration, info, autoplay: autoplay);
    return _OpenResult.opened;
  }
  return _OpenResult.player;
}

Future<void> _onOpened(
  PlaybackController c,
  EpisodeDetail detail,
  Narration narration,
  PlaybackInfo info, {
  required bool autoplay,
}) async {
  await c._player.setSpeed(c.playbackState.speed);
  c.updatePlaybackState(
    PlaybackState(
      episode: detail,
      narrationId: narration.id,
      status: PlaybackStatus.ready,
      playing: autoplay,
      durationMs: info.durationMs,
      speed: c.playbackState.speed,
      sleepEnabled: c.playbackState.sleepEnabled,
      request: c.playbackState.request,
    ),
  );
  await c._store.saveLastEpisode(
    LastListen(slug: detail.slug, narrationId: narration.id),
  );
  c.providerRef.invalidate(lastListenProvider);
  c._sync.begin(info);
  if (!autoplay) return;
  unawaited(c._player.play());
  unawaited(_askNotificationPermissionOnce(c));
}

MediaItem _mediaItem(EpisodeDetail detail, PlaybackInfo info) {
  final cover = detail.seriesCoverUrl;
  return MediaItem(
    id: info.narrationId,
    title: detail.title,
    album: detail.seriesTitle,
    duration: Duration(milliseconds: info.durationMs),
    artUri: cover == null ? null : Uri.tryParse(cover),
  );
}

/// [explicit] (narration switch) is kept, clamped inside the new audio;
/// otherwise the local position wins, then the server's, then zero.
Duration? _startPosition(
  PlaybackController c,
  PlaybackInfo info,
  Duration? explicit,
) {
  final durationSeconds = info.durationMs ~/ _millisPerSecond;
  if (explicit != null) {
    final lastValid = durationSeconds - AudioDefaults.resumeEndMarginSeconds;
    final maxMillis = (lastValid * _millisPerSecond).clamp(0, info.durationMs);
    return Duration(milliseconds: explicit.inMilliseconds.clamp(0, maxMillis));
  }
  final saved = c._store.position(info.narrationId);
  if (_validResume(saved, durationSeconds)) {
    return Duration(seconds: saved);
  }
  final serverMs = info.serverPositionMs;
  if (serverMs != null &&
      _validResume(serverMs ~/ _millisPerSecond, durationSeconds)) {
    return Duration(milliseconds: serverMs);
  }
  return Duration.zero;
}

bool _validResume(int seconds, int durationSeconds) =>
    seconds > AudioDefaults.resumeMinSeconds &&
    seconds < durationSeconds - AudioDefaults.resumeEndMarginSeconds;

PlaybackError _errorFor(AppException error) {
  if (error is ApiException &&
      (error.errorCode == contentUnavailableCode ||
          error.statusCode == _notFoundStatus)) {
    return PlaybackError.unavailable;
  }
  return PlaybackError.network;
}
