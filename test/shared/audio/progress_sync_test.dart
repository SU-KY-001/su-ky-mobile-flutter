import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:su_ky_mobile/core/error/app_exception.dart';
import 'package:su_ky_mobile/core/error/result.dart';
import 'package:su_ky_mobile/shared/audio/data/playback_repository.dart';
import 'package:su_ky_mobile/shared/audio/domain/playback_info.dart';
import 'package:su_ky_mobile/shared/audio/domain/played_bitmap.dart';
import 'package:su_ky_mobile/shared/audio/domain/progress_update.dart';
import 'package:su_ky_mobile/shared/audio/progress_sync.dart';

import '../../support/stub_http.dart';

const _narrationId = '0f8fad5b-d9cb-469f-a165-70867728950e';
const _assetId = '856983a0-c372-498b-a929-473af80aeadf';

Map<String, Object?> _playback({
  Object? url = 'https://cdn.test/a.mp3',
  Object? durationMs = 20000,
  Object? intervalMs = 15000,
  Object? progress,
  String narrationId = _narrationId,
  String assetId = _assetId,
}) => {
  'narrationId': narrationId,
  'episodeId': 'ep-1',
  'audio': {
    'assetId': assetId,
    'url': url,
    'mimeType': 'audio/mpeg',
    'durationMs': durationMs,
  },
  'progress': progress,
  'sync': {'intervalMs': intervalMs, 'completionThreshold': 0.9},
};

class _FakeRepo implements PlaybackRepository {
  final sent = <({int positionMs, String bitmap})>[];
  Result<ProgressUpdate> Function() answer = () => const Ok(ProgressUpdate());

  @override
  Future<Result<PlaybackInfo>> playback(String narrationId) =>
      throw UnimplementedError();

  @override
  Future<Result<ProgressUpdate>> updateProgress({
    required String narrationId,
    required String assetId,
    required int positionMs,
    required String playedBitmap,
  }) async {
    sent.add((positionMs: positionMs, bitmap: playedBitmap));
    return answer();
  }
}

PlaybackInfo _info({int durationMs = 20000}) => PlaybackInfo(
  narrationId: _narrationId,
  episodeId: 'ep',
  assetId: _assetId,
  url: Uri.parse('https://cdn.test/a.mp3'),
  durationMs: durationMs,
  syncInterval: const Duration(minutes: 5),
);

Duration _s(num s) => Duration(milliseconds: (s * 1000).round());

void main() {
  group('PlayedBitmap', () {
    test('sizes by ceil(seconds/8) and packs bits LSB first', () {
      final b = PlayedBitmap(20000)
        ..mark(0)
        ..mark(1)
        ..mark(8)
        ..mark(9);
      expect(b.totalSeconds, 20);
      final bytes = base64Decode(b.toBase64());
      expect(bytes.length, 3);
      expect(bytes[0], 0x03);
      expect(bytes[1], 0x03);
      expect(bytes[2], 0);
    });

    test('a partial second rounds up; out-of-range marks are ignored; clear empties', () {
      final b = PlayedBitmap(8500);
      expect(b.totalSeconds, 9);
      b
        ..mark(-1)
        ..mark(9)
        ..mark(100);
      expect(b.isEmpty, isTrue);
      b.mark(8);
      expect(base64Decode(b.toBase64()), [0, 1]);
      expect(b.isEmpty, isFalse);
      b.clear();
      expect(b.isEmpty, isTrue);
    });
  });

  group('ApiPlaybackRepository.playback', () {
    Future<Result<PlaybackInfo>> run(
      Object body, {
      int status = 200,
      String id = _narrationId,
    }) =>
        ApiPlaybackRepository(stubDio((_) => StubReply(status, body)).$1)
            .playback(id);

    test(
      'parses audio, server position and clamps a tiny sync interval',
      () async {
        final r = await run(
          _playback(intervalMs: 1000, progress: {'positionMs': 12500}),
        );
        final i = (r as Ok<PlaybackInfo>).value;
        expect(i.syncInterval, const Duration(seconds: 5));
        expect(i.serverPositionMs, 12500);
        expect(i.assetId, _assetId);
      },
    );

    test('guest response (progress null) has no server position', () async {
      final r = await run(_playback());
      expect((r as Ok<PlaybackInfo>).value.serverPositionMs, isNull);
    });

    test('a malformed progress block is ignored, not fatal', () async {
      final r = await run(_playback(progress: {'positionMs': 'x'}));
      expect((r as Ok<PlaybackInfo>).value.serverPositionMs, isNull);
    });

    test(
      'rejects a non-https url, zero duration and a mismatched id',
      () async {
        expect(
          await run(_playback(url: 'http://cdn.test/a.mp3')),
          isA<Err<PlaybackInfo>>(),
        );
        expect(await run(_playback(durationMs: 0)), isA<Err<PlaybackInfo>>());
        expect(
          await run(
            _playback(narrationId: '11111111-1111-1111-1111-111111111111'),
          ),
          isA<Err<PlaybackInfo>>(),
        );
        expect(
          await run(_playback(assetId: 'not-a-uuid')),
          isA<Err<PlaybackInfo>>(),
        );
      },
    );

    test('a non-uuid id is rejected before any request', () async {
      final (dio, adapter) = stubDio((_) => const StubReply(200, {}));
      final r = await ApiPlaybackRepository(dio).playback('abc');
      expect(r, isA<Err<PlaybackInfo>>());
      expect(adapter.requests, isEmpty);
    });

    test('CONTENT_UNAVAILABLE keeps its code', () async {
      final r = await run({
        'error_code': contentUnavailableCode,
        'message': 'x',
      }, status: 409);
      expect(
        ((r as Err<PlaybackInfo>).error as ApiException).errorCode,
        contentUnavailableCode,
      );
    });
  });

  group('ApiPlaybackRepository.updateProgress', () {
    test('sends the body and reads a completion', () async {
      final (dio, adapter) = stubDio(
        (_) => const StubReply(200, {
          'narrationId': _narrationId,
          'positionMs': 1000,
          'completion': {'xpAwarded': 10, 'totalXp': 130},
        }),
      );
      final r = await ApiPlaybackRepository(dio).updateProgress(
        narrationId: _narrationId,
        assetId: _assetId,
        positionMs: 1000,
        playedBitmap: 'AQ==',
      );
      expect((r as Ok<ProgressUpdate>).value.completion?.totalXp, 130);
      expect(adapter.requests.single.method, 'PUT');
      expect(adapter.requests.single.data, {
        'assetId': _assetId,
        'positionMs': 1000,
        'playedBitmap': 'AQ==',
      });
    });

    test('invalid payloads are refused locally', () async {
      final (dio, adapter) = stubDio((_) => const StubReply(200, {}));
      final repo = ApiPlaybackRepository(dio);
      Future<Result<ProgressUpdate>> call({
        String asset = _assetId,
        int pos = 0,
        String bmp = 'AQ==',
      }) => repo.updateProgress(
        narrationId: _narrationId,
        assetId: asset,
        positionMs: pos,
        playedBitmap: bmp,
      );
      expect(await call(asset: 'x'), isA<Err<ProgressUpdate>>());
      expect(await call(pos: -1), isA<Err<ProgressUpdate>>());
      expect(await call(bmp: 'A' * 4097), isA<Err<ProgressUpdate>>());
      expect(
        await call(bmp: 'A' * 4096),
        isA<Err<ProgressUpdate>>(),
        reason: 'accepted locally but server answers {} which is malformed',
      );
      expect(adapter.requests.length, 1);
    });

    test('a malformed completion is an error', () async {
      final r =
          await ApiPlaybackRepository(
            stubDio(
              (_) => const StubReply(200, {
                'narrationId': _narrationId,
                'positionMs': 0,
                'completion': {'xpAwarded': -1, 'totalXp': 1},
              }),
            ).$1,
          ).updateProgress(
            narrationId: _narrationId,
            assetId: _assetId,
            positionMs: 0,
            playedBitmap: 'AQ==',
          );
      expect(r, isA<Err<ProgressUpdate>>());
    });
  });

  group('ProgressSync', () {
    late _FakeRepo repo;
    late List<ListeningCompletion> completions;
    late bool signedIn;
    late ProgressSync sync;

    setUp(() {
      repo = _FakeRepo();
      completions = [];
      signedIn = true;
      sync = ProgressSync(
        repository: repo,
        isSignedIn: () => signedIn,
        onCompleted: completions.add,
      )..begin(_info());
    });
    tearDown(() => sync.end());

    void play(Iterable<num> seconds) {
      for (final s in seconds) {
        sync.onPosition(_s(s), playing: true);
      }
    }

    test('nothing is sent until seconds were actually played', () async {
      await sync.flush();
      expect(repo.sent, isEmpty);
    });

    test('marks the seconds played between ticks and sends them', () async {
      play([0, 1, 2, 3]);
      await sync.flush();
      expect(repo.sent.single.positionMs, 3000);
      expect(base64Decode(repo.sent.single.bitmap).first, 0x07);
      await sync.flush();
      expect(repo.sent.length, 1, reason: 'clean after success');
    });

    test('a seek marks nothing and a long jump is not counted', () async {
      play([0, 1]);
      sync.onSeek();
      play([10, 11]);
      await sync.flush();
      final b = base64Decode(repo.sent.single.bitmap);
      expect(b[0], 0x01, reason: 'only second 0 (0->1) and 10->11 are played');
      expect(b[1], 0x04);

      repo.sent.clear();
      play([30]);
      await sync.flush();
      expect(repo.sent, isEmpty, reason: 'a 19s jump (> 5s) is not marked');
    });

    test('paused or signed-out playback marks nothing', () async {
      sync.onPosition(_s(0), playing: false);
      sync.onPosition(_s(1), playing: false);
      signedIn = false;
      play([2, 3]);
      await sync.flush(force: true);
      expect(repo.sent, isEmpty);
    });

    test('completion reaches the callback', () async {
      repo.answer = () => const Ok(
        ProgressUpdate(
          completion: ListeningCompletion(xpAwarded: 10, totalXp: 50),
        ),
      );
      play([0, 1]);
      await sync.flush();
      expect(completions.single.xpAwarded, 10);
    });

    test('429 and network errors stay dirty and retry', () async {
      repo.answer = () => const Err(NetworkException('down'));
      play([0, 1]);
      await sync.flush();
      repo.answer = () => const Ok(ProgressUpdate());
      await sync.flush();
      expect(repo.sent.length, 2);
    });

    test('AUDIO_CHANGED disables sync for the narration', () async {
      repo.answer = () => const Err(
        ApiException('x', statusCode: 409, errorCode: 'AUDIO_CHANGED'),
      );
      play([0, 1]);
      await sync.flush();
      play([2, 3]);
      await sync.flush(force: true);
      expect(repo.sent.length, 1);
    });

    test('PROGRESS_INVALID clears the bitmap', () async {
      repo.answer = () => const Err(
        ApiException('x', statusCode: 422, errorCode: 'PROGRESS_INVALID'),
      );
      play([0, 1]);
      await sync.flush();
      repo.answer = () => const Ok(ProgressUpdate());
      await sync.flush(force: true);
      expect(base64Decode(repo.sent.last.bitmap).every((b) => b == 0), isTrue);
    });

    test(
      'end() sends seconds played while a send was in flight',
      skip: 'BUG-01, xem docs/reports/p11-test-findings.md',
      () async {
        play([0, 1]);
        final first = sync.flush();
        play([2, 3]);
        await sync.end();
        await first;
        expect(repo.sent.length, 2);
        expect(base64Decode(repo.sent.last.bitmap).first, 0x07);
      },
    );

    test('rearm lets a finished episode be played again', () async {
      play([0, 1]);
      await sync.flush();
      sync.rearm();
      sync.onPosition(Duration.zero, playing: true);
      play([1]);
      await sync.flush();
      expect(repo.sent.length, 2);
    });
  });
}
