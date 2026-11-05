import 'package:dio/dio.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/error/result.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/network/dio_factory.dart';
import '../domain/weekly_missions.dart';

const _missionsPath = '/api/me/weekly-missions';

abstract class WeeklyMissionsRepository {
  Future<Result<WeeklyMissions>> fetch();
}

class ApiWeeklyMissionsRepository implements WeeklyMissionsRepository {
  ApiWeeklyMissionsRepository(this._dio);

  final Dio _dio;

  @override
  Future<Result<WeeklyMissions>> fetch() async {
    try {
      final res = await _dio.get<Object?>(_missionsPath);
      return Ok(_parse(res.data));
    } on DioException catch (e) {
      final error = e.error;
      return Err(error is AppException ? error : mapDioException(e));
    } on AppException catch (e) {
      return Err(e);
    } on FormatException catch (e, stack) {
      AppLogger.error(
        'Weekly missions: unexpected payload',
        error: e,
        stackTrace: stack,
      );
      return Err(
        UnknownException('Weekly missions: unexpected payload', cause: e),
      );
    } catch (e, stack) {
      AppLogger.error('Weekly missions failed', error: e, stackTrace: stack);
      return Err(UnknownException('Weekly missions failed', cause: e));
    }
  }

  WeeklyMissions _parse(Object? body) {
    final json = _object(body, 'weekly missions');
    final items = <WeeklyMission>[];
    for (final value in _list(json, 'items')) {
      final mission = _mission(value);
      if (mission != null) items.add(mission);
    }
    return WeeklyMissions(
      totalXp: _int(json, 'totalXp'),
      weekEnd: _date(json, 'weekEndDate').toUtc(),
      items: items,
    );
  }

  /// Unknown activity/status values are skipped (and logged) so one new
  /// server-side mission kind never breaks the whole screen.
  WeeklyMission? _mission(Object? value) {
    final json = _object(value, 'mission');
    final activity = _activity(_string(json, 'activityType'));
    if (activity == null) return null;
    final status = _status(_string(json, 'status'));
    if (status == null) return null;
    return WeeklyMission(
      id: _string(json, 'id'),
      title: _string(json, 'title'),
      activity: activity,
      targetCount: _int(json, 'targetCount'),
      progressCount: _int(json, 'progressCount'),
      xpReward: _int(json, 'xpReward'),
      status: status,
    );
  }

  MissionActivity? _activity(String value) {
    switch (value) {
      case 'COMPLETE_EPISODE':
        return MissionActivity.completeEpisode;
      case 'PASS_QUIZ':
        return MissionActivity.passQuiz;
      default:
        _logSkipped('activityType', value);
        return null;
    }
  }

  MissionStatus? _status(String value) {
    switch (value) {
      case 'IN_PROGRESS':
        return MissionStatus.inProgress;
      case 'COMPLETED':
        return MissionStatus.completed;
      case 'EXPIRED':
        return MissionStatus.expired;
      default:
        _logSkipped('status', value);
        return null;
    }
  }

  void _logSkipped(String field, String value) {
    AppLogger.error(
      'Weekly missions: ignoring unknown $field "$value"',
      error: FormatException('Unknown $field'),
      stackTrace: StackTrace.current,
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

  int _int(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is int && value >= 0) return value;
    throw FormatException('Field "$key" must be an int >= 0');
  }

  DateTime _date(Map<String, Object?> json, String key) {
    final date = DateTime.tryParse(_string(json, key));
    if (date == null) throw FormatException('Field "$key" must be a date');
    return date;
  }
}
