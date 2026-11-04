import 'package:dio/dio.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/error/result.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/network/dio_factory.dart';
import '../domain/release.dart';

const _releasesPath = '/api/showcase/releases';

abstract class ScheduleRepository {
  /// Releases from the first day of [monthStart] up to, not including, the
  /// first day of the following month.
  Future<Result<List<Release>>> month(DateTime monthStart);
}

class ApiScheduleRepository implements ScheduleRepository {
  ApiScheduleRepository(this._dio);

  final Dio _dio;

  @override
  Future<Result<List<Release>>> month(DateTime monthStart) async {
    final start = DateTime(monthStart.year, monthStart.month);
    final end = DateTime(monthStart.year, monthStart.month + 1);
    try {
      final res = await _dio.get<Object?>(
        _releasesPath,
        queryParameters: {
          'from': start.toUtc().toIso8601String(),
          'to': end.toUtc().toIso8601String(),
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
        'Release schedule: unexpected payload',
        error: e,
        stackTrace: stack,
      );
      return Err(
        UnknownException('Release schedule: unexpected payload', cause: e),
      );
    } catch (e, stack) {
      AppLogger.error('Release schedule failed', error: e, stackTrace: stack);
      return Err(UnknownException('Release schedule failed', cause: e));
    }
  }

  List<Release> _parse(Object? body) {
    final json = _object(body, 'release schedule');
    final items = <Release>[];
    for (final value in _list(json, 'items')) {
      try {
        items.add(_release(value));
      } on FormatException catch (e, stack) {
        AppLogger.error(
          'Release schedule: skipping malformed release',
          error: e,
          stackTrace: stack,
        );
      }
    }
    items.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return items;
  }

  Release _release(Object? value) {
    final json = _object(value, 'release');
    final series = _object(json['series'], 'series');
    return Release(
      id: _string(json, 'id'),
      title: _string(json, 'title'),
      scheduledAt: _date(json, 'scheduledAt').toUtc(),
      released: _bool(json, 'released'),
      episodeSlug: _string(json, 'episodeSlug'),
      seriesTitle: _string(series, 'title'),
    );
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

  DateTime _date(Map<String, Object?> json, String key) {
    final date = DateTime.tryParse(_string(json, key));
    if (date == null) throw FormatException('Field "$key" must be a date');
    return date;
  }
}
