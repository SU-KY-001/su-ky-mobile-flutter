import 'package:dio/dio.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/error/result.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/network/dio_factory.dart';
import '../domain/listening_history.dart';

const _historyPath = '/api/me/listening-history';
const _historyPage = 1;
const _historyLimit = 10;
const _historyStatus = 'all';
const _zeroPercent = 0.0;

abstract class HistoryRepository {
  /// Newest first. `limit` is capped at 50 by the API.
  Future<Result<ListeningHistory>> recent({int limit = _historyLimit});
}

class ApiHistoryRepository implements HistoryRepository {
  ApiHistoryRepository(this._dio);

  final Dio _dio;

  @override
  Future<Result<ListeningHistory>> recent({int limit = _historyLimit}) async {
    try {
      final res = await _dio.get<Object?>(
        _historyPath,
        queryParameters: {
          'page': _historyPage,
          'limit': limit,
          'status': _historyStatus,
        },
      );
      return Ok(_parse(res.data));
    } on DioException catch (e) {
      final error = e.error;
      return Err(error is AppException ? error : mapDioException(e));
    } on AppException catch (e) {
      return Err(e);
    } on FormatException catch (e, stack) {
      AppLogger.error(
        'Listening history: unexpected payload',
        error: e,
        stackTrace: stack,
      );
      return Err(
        UnknownException('Listening history: unexpected payload', cause: e),
      );
    } catch (e, stack) {
      AppLogger.error('Listening history failed', error: e, stackTrace: stack);
      return Err(UnknownException('Listening history failed', cause: e));
    }
  }

  ListeningHistory _parse(Object? body) {
    final json = _object(body, 'listening history');
    final items = <HistoryEntry>[];
    for (final value in _list(json, 'items')) {
      try {
        items.add(_entry(value));
      } on FormatException catch (e, stack) {
        AppLogger.error(
          'Listening history: skipping malformed entry',
          error: e,
          stackTrace: stack,
        );
      }
    }
    return ListeningHistory(items: items);
  }

  HistoryEntry _entry(Object? value) {
    final json = _object(value, 'history entry');
    final episode = _object(json['episode'], 'episode');
    final series = _object(episode['series'], 'series');
    return HistoryEntry(
      episodeSlug: _string(episode, 'slug'),
      episodeTitle: _string(episode, 'title'),
      seriesTitle: _string(series, 'title'),
      available: _bool(episode, 'available'),
      narrationId: _string(json, 'lastNarrationId'),
      percent: _percent(json, 'percent'),
    );
  }

  /// The API may send a decimal percentage (`82.18`); the UI shows it rounded.
  int _percent(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is! num) {
      throw FormatException('Field "$key" must be a number');
    }
    return value.clamp(_zeroPercent, historyPercentMax).round();
  }

  Map<String, Object?> _object(Object? value, String what) {
    if (value is Map<String, Object?>) return value;
    throw FormatException('Expected $what to be an object');
  }

  List<Object?> _list(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is List<Object?>) return value;
    throw FormatException('Field "$key" must be a list');
  }

  String _string(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
    throw FormatException('Field "$key" must be a non-empty string');
  }

  bool _bool(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is bool) return value;
    throw FormatException('Field "$key" must be a bool');
  }
}
