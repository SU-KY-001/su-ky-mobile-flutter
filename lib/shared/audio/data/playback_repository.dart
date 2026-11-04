import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/result.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/network/dio_factory.dart';
import '../audio_defaults.dart';
import '../domain/playback_info.dart';
import '../domain/progress_update.dart';

const _narrationsPath = '/api/narrations';
const _progressPath = '/api/me/listening-progress';
const _badRequestStatus = 400;
const _badRequestCode = 'BAD_REQUEST';
const _maxPlayedBitmapChars = 4096;

/// Error code the API uses when a narration has no ready audio.
const contentUnavailableCode = 'CONTENT_UNAVAILABLE';

final _uuidPattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
);

abstract class PlaybackRepository {
  Future<Result<PlaybackInfo>> playback(String narrationId);

  Future<Result<ProgressUpdate>> updateProgress({
    required String narrationId,
    required String assetId,
    required int positionMs,
    required String playedBitmap,
  });
}

class ApiPlaybackRepository implements PlaybackRepository {
  ApiPlaybackRepository(this._dio);

  final Dio _dio;

  @override
  Future<Result<PlaybackInfo>> playback(String narrationId) async {
    if (!_uuidPattern.hasMatch(narrationId)) {
      return const Err(
        ApiException(
          'Invalid narration id',
          statusCode: _badRequestStatus,
          errorCode: _badRequestCode,
        ),
      );
    }
    try {
      final res = await _dio.get<Object?>(
        '$_narrationsPath/$narrationId/playback',
      );
      return Ok(_parse(res.data, narrationId));
    } on DioException catch (e) {
      final error = e.error;
      return Err(error is AppException ? error : mapDioException(e));
    } on AppException catch (e) {
      return Err(e);
    } on FormatException catch (e, stack) {
      AppLogger.error(
        'Playback: unexpected payload',
        error: e,
        stackTrace: stack,
      );
      return Err(UnknownException('Playback: unexpected payload', cause: e));
    }
  }

  @override
  Future<Result<ProgressUpdate>> updateProgress({
    required String narrationId,
    required String assetId,
    required int positionMs,
    required String playedBitmap,
  }) async {
    final invalid =
        !_uuidPattern.hasMatch(narrationId) ||
        !_uuidPattern.hasMatch(assetId) ||
        positionMs < 0 ||
        playedBitmap.length > _maxPlayedBitmapChars;
    if (invalid) {
      return const Err(
        ApiException(
          'Invalid progress payload',
          statusCode: _badRequestStatus,
          errorCode: _badRequestCode,
        ),
      );
    }
    try {
      final res = await _dio.put<Object?>(
        '$_progressPath/$narrationId',
        data: {
          'assetId': assetId,
          'positionMs': positionMs,
          'playedBitmap': playedBitmap,
        },
        options: Options(
          sendTimeout: AudioDefaults.progressTimeout,
          receiveTimeout: AudioDefaults.progressTimeout,
        ),
      );
      return Ok(_parseProgress(res.data, narrationId));
    } on DioException catch (e) {
      final error = e.error;
      return Err(error is AppException ? error : mapDioException(e));
    } on AppException catch (e) {
      return Err(e);
    } on FormatException catch (e, stack) {
      AppLogger.error(
        'Progress: unexpected payload',
        error: e,
        stackTrace: stack,
      );
      return Err(UnknownException('Progress: unexpected payload', cause: e));
    }
  }

  /// Validates the payload; the id must echo the one requested.
  PlaybackInfo _parse(Object? body, String requestedId) {
    if (body is! Map<String, Object?>) {
      throw const FormatException('Expected playback to be an object');
    }
    final narrationId = _string(body, 'narrationId');
    if (narrationId != requestedId) {
      throw const FormatException('Field "narrationId" does not match');
    }
    final audio = body['audio'];
    if (audio is! Map<String, Object?>) {
      throw const FormatException('Field "audio" must be an object');
    }
    final assetId = _string(audio, 'assetId');
    if (!_uuidPattern.hasMatch(assetId)) {
      throw const FormatException('Field "audio.assetId" must be a UUID');
    }
    final url = Uri.tryParse(_string(audio, 'url'));
    if (url == null || url.scheme != 'https' || url.host.isEmpty) {
      throw const FormatException('Field "audio.url" must be an https URL');
    }
    final durationMs = audio['durationMs'];
    if (durationMs is! int || durationMs <= 0) {
      throw const FormatException('Field "audio.durationMs" must be > 0');
    }
    final sync = body['sync'];
    if (sync is! Map<String, Object?>) {
      throw const FormatException('Field "sync" must be an object');
    }
    final intervalMs = sync['intervalMs'];
    if (intervalMs is! int || intervalMs <= 0) {
      throw const FormatException('Field "sync.intervalMs" must be > 0');
    }
    final minIntervalMs = AudioDefaults.minSyncInterval.inMilliseconds;
    return PlaybackInfo(
      narrationId: narrationId,
      episodeId: _string(body, 'episodeId'),
      assetId: assetId,
      url: url,
      durationMs: durationMs,
      syncInterval: Duration(
        milliseconds: intervalMs < minIntervalMs ? minIntervalMs : intervalMs,
      ),
      serverPositionMs: _serverPosition(body['progress']),
    );
  }

  ProgressUpdate _parseProgress(Object? body, String requestedId) {
    if (body is! Map<String, Object?>) {
      throw const FormatException('Expected progress to be an object');
    }
    final narrationId = _string(body, 'narrationId');
    if (narrationId != requestedId) {
      throw const FormatException('Field "narrationId" does not match');
    }
    final positionMs = body['positionMs'];
    if (positionMs is! int || positionMs < 0) {
      throw const FormatException('Field "positionMs" must be >= 0');
    }
    return ProgressUpdate(completion: _completion(body['completion']));
  }

  ListeningCompletion? _completion(Object? value) {
    if (value == null) return null;
    if (value is Map<String, Object?>) {
      final xpAwarded = value['xpAwarded'];
      final totalXp = value['totalXp'];
      if (xpAwarded is int &&
          xpAwarded >= 0 &&
          totalXp is int &&
          totalXp >= 0) {
        return ListeningCompletion(xpAwarded: xpAwarded, totalXp: totalXp);
      }
    }
    throw const FormatException('Field "completion" is malformed');
  }

  /// Progress is optional and never blocks playback; a bad shape logs and
  /// behaves like no server progress.
  int? _serverPosition(Object? progress) {
    if (progress == null) return null;
    if (progress is Map<String, Object?>) {
      final positionMs = progress['positionMs'];
      if (positionMs is int && positionMs >= 0) return positionMs;
    }
    AppLogger.error(
      'Playback: ignoring malformed progress',
      error: const FormatException('Field "progress" is malformed'),
      stackTrace: StackTrace.current,
    );
    return null;
  }

  String _string(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
    throw FormatException('Field "$key" must be a non-empty string');
  }
}

final playbackRepositoryProvider = Provider<PlaybackRepository>(
  (ref) => ApiPlaybackRepository(ref.watch(dioProvider)),
);
