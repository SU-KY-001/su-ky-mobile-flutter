import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/result.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/network/dio_factory.dart';
import '../domain/playback_info.dart';

const _narrationsPath = '/api/narrations';
const _badRequestStatus = 400;
const _invalidIdCode = 'BAD_REQUEST';

/// Error code the API uses when a narration has no ready audio.
const contentUnavailableCode = 'CONTENT_UNAVAILABLE';

final _uuidPattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
);

abstract class PlaybackRepository {
  Future<Result<PlaybackInfo>> playback(String narrationId);
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
          errorCode: _invalidIdCode,
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
    final url = Uri.tryParse(_string(audio, 'url'));
    if (url == null || url.scheme != 'https' || url.host.isEmpty) {
      throw const FormatException('Field "audio.url" must be an https URL');
    }
    final durationMs = audio['durationMs'];
    if (durationMs is! int || durationMs <= 0) {
      throw const FormatException('Field "audio.durationMs" must be > 0');
    }
    return PlaybackInfo(
      narrationId: narrationId,
      episodeId: _string(body, 'episodeId'),
      url: url,
      durationMs: durationMs,
    );
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
