import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:su_ky_mobile/core/auth/signed_in.dart';
import 'package:su_ky_mobile/core/di/providers.dart';
import 'package:su_ky_mobile/core/error/app_exception.dart';
import 'package:su_ky_mobile/core/error/result.dart';
import 'package:su_ky_mobile/shared/audio/data/playback_repository.dart';
import 'package:su_ky_mobile/shared/audio/domain/playback_info.dart';
import 'package:su_ky_mobile/shared/audio/domain/progress_update.dart';
import 'package:su_ky_mobile/shared/audio/playback_controller.dart';
import 'package:su_ky_mobile/shared/audio/playback_providers.dart';
import 'package:su_ky_mobile/shared/audio/playback_state.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_providers.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode_detail.dart';

const _narrationId = '0f8fad5b-d9cb-469f-a165-70867728950e';
const _assetId = '856983a0-c372-498b-a929-473af80aeadf';

class _FakePlayer extends Fake implements AudioPlayer {
  final _state = StreamController<PlayerState>.broadcast();
  final _pos = StreamController<Duration>.broadcast();
  Duration position0 = Duration.zero;
  Duration? lastInitialPosition;
  Object? openError;
  int opens = 0;
  int plays = 0;
  int stops = 0;
  final seeks = <Duration>[];

  @override
  Stream<PlayerState> get playerStateStream => _state.stream;
  @override
  Stream<Duration> get positionStream => _pos.stream;
  @override
  Duration get position => position0;

  @override
  Future<Duration?> setAudioSource(
    AudioSource source, {
    bool preload = true,
    int? initialIndex,
    Duration? initialPosition,
  }) async {
    opens++;
    lastInitialPosition = initialPosition;
    final error = openError;
    if (error != null) throw error;
    return null;
  }

  @override
  Future<void> setSpeed(double speed) async {}
  @override
  Future<void> play() async => plays++;
  @override
  Future<void> pause() async {}
  @override
  Future<void> stop() async => stops++;
  @override
  Future<void> seek(Duration? position, {int? index}) async =>
      seeks.add(position ?? Duration.zero);
  @override
  Future<void> dispose() async {}
}

class _Repo implements PlaybackRepository {
  _Repo({this.durationMs = 120000, this.serverPositionMs});
  final int durationMs;
  final int? serverPositionMs;
  int calls = 0;
  Result<PlaybackInfo>? fail;

  @override
  Future<Result<PlaybackInfo>> playback(String narrationId) async {
    calls++;
    return fail ??
        Ok(
          PlaybackInfo(
            narrationId: narrationId,
            episodeId: 'e',
            assetId: _assetId,
            url: Uri.parse('https://cdn.test/a.mp3'),
            durationMs: durationMs,
            syncInterval: const Duration(minutes: 5),
            serverPositionMs: serverPositionMs,
          ),
        );
  }

  @override
  Future<Result<ProgressUpdate>> updateProgress({
    required String narrationId,
    required String assetId,
    required int positionMs,
    required String playedBitmap,
  }) async => const Ok(ProgressUpdate());
}

const _episode = EpisodeDetail(
  id: 'e',
  slug: 'ep-1',
  title: 'Ep',
  seriesSlug: 's',
  seriesTitle: 'S',
  hasQuiz: false,
  narrations: [
    Narration(
      id: _narrationId,
      type: NarrationType.firstPerson,
      available: true,
    ),
  ],
);

Future<(ProviderContainer, _FakePlayer, _Repo)> _setup({
  bool signedIn = true,
  Map<String, Object> prefs = const {},
  _Repo? repo,
  EpisodeDetail episode = _episode,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final player = _FakePlayer();
  final fakeRepo = repo ?? _Repo();
  final c = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(
        await SharedPreferences.getInstance(),
      ),
      audioPlayerProvider.overrideWithValue(player),
      playbackRepositoryProvider.overrideWithValue(fakeRepo),
      signedInProvider.overrideWith((ref) => signedIn),
      episodeDetailProvider.overrideWith((ref, slug) async => episode),
    ],
  );
  addTearDown(c.dispose);
  c.listen(playbackControllerProvider, (_, _) {});
  return (c, player, fakeRepo);
}

PlaybackController _ctrl(ProviderContainer c) =>
    c.read(playbackControllerProvider.notifier);

void main() {
  group('start position', () {
    Future<Duration?> startFor(
      Map<String, Object> prefs, {
      int? serverMs,
      int durationMs = 120000,
    }) async {
      final (c, player, _) = await _setup(
        prefs: prefs,
        repo: _Repo(durationMs: durationMs, serverPositionMs: serverMs),
      );
      await _ctrl(c).playEpisode('ep-1');
      return player.lastInitialPosition;
    }

    test('starts from zero with no saved position', () async {
      expect(await startFor({}), Duration.zero);
    });

    test('local position wins over the server one', () async {
      expect(
        await startFor({'playback.pos.$_narrationId': 40}, serverMs: 70000),
        const Duration(seconds: 40),
      );
    });

    test(
      'falls back to the server position when nothing is saved locally',
      () async {
        expect(
          await startFor({}, serverMs: 70500),
          const Duration(milliseconds: 70500),
        );
      },
    );

    test(
      'a position at the very start or near the end is not restored',
      () async {
        expect(
          await startFor({'playback.pos.$_narrationId': 1}),
          Duration.zero,
        );
        expect(
          await startFor({'playback.pos.$_narrationId': 119}),
          Duration.zero,
        );
        expect(await startFor({}, serverMs: 119000), Duration.zero);
      },
    );
  });

  group('playEpisode', () {
    test('a guest gets needsLogin and nothing is loaded', () async {
      final (c, player, repo) = await _setup(signedIn: false);
      expect(await _ctrl(c).playEpisode('ep-1'), PlayOutcome.needsLogin);
      expect(player.opens, 0);
      expect(repo.calls, 0);
      expect(c.read(playbackControllerProvider).status, PlaybackStatus.idle);
    });

    test(
      'a signed-in user starts playing and the last episode is saved',
      () async {
        final (c, player, _) = await _setup();
        expect(await _ctrl(c).playEpisode('ep-1'), PlayOutcome.started);
        final s = c.read(playbackControllerProvider);
        expect(s.status, PlaybackStatus.ready);
        expect(s.playing, isTrue);
        expect(s.durationMs, 120000);
        expect(player.plays, 1);
        expect(
          c.read(sharedPreferencesProvider).getString('playback.lastEpisode'),
          contains('ep-1'),
        );
      },
    );

    test(
      'playing the loaded episode again resumes without reloading',
      () async {
        final (c, player, repo) = await _setup();
        await _ctrl(c).playEpisode('ep-1');
        await _ctrl(c).playEpisode('ep-1');
        expect(repo.calls, 1);
        expect(player.opens, 1);
        expect(player.plays, 2);
      },
    );

    test('an episode without a playable narration is unavailable', () async {
      const silent = EpisodeDetail(
        id: 'e',
        slug: 'ep-1',
        title: 'Ep',
        seriesSlug: 's',
        seriesTitle: 'S',
        hasQuiz: false,
        narrations: [
          Narration(
            id: _narrationId,
            type: NarrationType.firstPerson,
            available: false,
          ),
        ],
      );
      final (c, player, _) = await _setup(episode: silent);
      expect(await _ctrl(c).playEpisode('ep-1'), PlayOutcome.failed);
      final s = c.read(playbackControllerProvider);
      expect(s.status, PlaybackStatus.error);
      expect(s.error, PlaybackError.unavailable);
      expect(player.stops, 1);
    });

    test(
      'CONTENT_UNAVAILABLE maps to unavailable, other API failures to network',
      () async {
        final (c, _, repo) = await _setup();
        repo.fail = const Err(
          ApiException('x', statusCode: 409, errorCode: 'CONTENT_UNAVAILABLE'),
        );
        await _ctrl(c).playEpisode('ep-1');
        expect(
          c.read(playbackControllerProvider).error,
          PlaybackError.unavailable,
        );

        repo.fail = const Err(NetworkException('down'));
        await _ctrl(c).playEpisode('ep-1');
        expect(c.read(playbackControllerProvider).error, PlaybackError.network);
      },
    );

    test(
      'a failing audio source is retried once with a fresh URL, then reported',
      () async {
        final (c, player, repo) = await _setup();
        player.openError = StateError('expired');
        await _ctrl(c).playEpisode('ep-1');
        expect(repo.calls, 2);
        expect(player.opens, 2);
        expect(c.read(playbackControllerProvider).error, PlaybackError.player);
      },
    );

    test('Play after an error retries the last request', () async {
      final (c, _, repo) = await _setup();
      repo.fail = const Err(NetworkException('down'));
      await _ctrl(c).playEpisode('ep-1');
      repo.fail = null;
      await _ctrl(c).togglePlayPause();
      expect(c.read(playbackControllerProvider).status, PlaybackStatus.ready);
    });
  });

  group('guest Play request survives sign-in', () {
    test('plays after sign-in', () async {
      final signedIn = NotifierProvider<_Flag, bool>(_Flag.new);
      SharedPreferences.setMockInitialValues({});
      final player = _FakePlayer();
      final c = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(
            await SharedPreferences.getInstance(),
          ),
          audioPlayerProvider.overrideWithValue(player),
          playbackRepositoryProvider.overrideWithValue(_Repo()),
          signedInProvider.overrideWith((ref) => ref.watch(signedIn)),
          episodeDetailProvider.overrideWith((ref, slug) async => _episode),
        ],
      );
      addTearDown(c.dispose);
      c.listen(playbackControllerProvider, (_, _) {});
      await _ctrl(c).playEpisode('ep-1');
      expect(player.opens, 0);

      c.read(signedIn.notifier).set(true);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(player.opens, 1);
      expect(c.read(playbackControllerProvider).status, PlaybackStatus.ready);
    });

    test('a cancelled request is dropped', () async {
      final signedIn = NotifierProvider<_Flag, bool>(_Flag.new);
      SharedPreferences.setMockInitialValues({});
      final player = _FakePlayer();
      final c = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(
            await SharedPreferences.getInstance(),
          ),
          audioPlayerProvider.overrideWithValue(player),
          playbackRepositoryProvider.overrideWithValue(_Repo()),
          signedInProvider.overrideWith((ref) => ref.watch(signedIn)),
          episodeDetailProvider.overrideWith((ref, slug) async => _episode),
        ],
      );
      addTearDown(c.dispose);
      c.listen(playbackControllerProvider, (_, _) {});
      await _ctrl(c).playEpisode('ep-1');
      _ctrl(c).cancelPendingPlay();
      c.read(signedIn.notifier).set(true);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(player.opens, 0);
    });
  });

  group('controls', () {
    test('skip clamps inside the track and speed cycles', () async {
      final (c, player, _) = await _setup();
      await _ctrl(c).playEpisode('ep-1');
      player.position0 = const Duration(seconds: 5);
      await _ctrl(c).skip(-15);
      expect(player.seeks.last, Duration.zero);
      player.position0 = const Duration(seconds: 115);
      await _ctrl(c).skip(15);
      expect(player.seeks.last, const Duration(milliseconds: 120000));

      await _ctrl(c).cycleSpeed();
      expect(c.read(playbackControllerProvider).speed, 1.25);
      for (var i = 0; i < 4; i++) {
        await _ctrl(c).cycleSpeed();
      }
      expect(c.read(playbackControllerProvider).speed, 1.0);
    });

    test('controls do nothing before an episode is loaded', () async {
      final (c, player, _) = await _setup();
      await _ctrl(c).skip(15);
      await _ctrl(c).seekToRatio(0.5);
      expect(player.seeks, isEmpty);
    });
  });
}

class _Flag extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool value) => state = value;
}
