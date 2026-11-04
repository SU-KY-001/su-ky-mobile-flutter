import '../../../core/logging/app_logger.dart';
import '../catalog_constants.dart';
import '../domain/historical_event.dart';
import 'json_fields.dart';

/// Validates historical-event JSON field by field; the raw map never leaves
/// this file. Every parse function throws [FormatException] naming the bad
/// field.
abstract final class HistoricalEventParser {
  /// Parses one page of events. A broken row is skipped and logged so one
  /// bad record cannot hide the whole history; a missing `items` list is a
  /// broken response and fails the request.
  static List<HistoricalEvent> list(Object? body) {
    final json = JsonFields.object(body, 'historical events');
    final events = <HistoricalEvent>[];
    for (final item in JsonFields.list(json, 'items')) {
      try {
        events.add(_event(item));
      } on FormatException catch (error, stack) {
        AppLogger.error(
          'Historical events: row skipped',
          error: error,
          stackTrace: stack,
        );
      }
    }
    return events;
  }

  /// Parses one event. Any invalid field fails the whole request.
  static HistoricalEvent detail(Object? body) => _event(body);

  static HistoricalEvent _event(Object? body) {
    final json = JsonFields.object(body, 'historical event');
    final parent = JsonFields.object(json['parent'], 'parent');
    return HistoricalEvent(
      id: JsonFields.string(json, 'id'),
      slug: _slug(json),
      name: JsonFields.string(json, 'name'),
      summary: JsonFields.string(json, 'summary'),
      timeLabel: JsonFields.string(json, 'timeLabel'),
      periodName: JsonFields.string(
        JsonFields.object(parent['period'], 'parent.period'),
        'name',
      ),
      phaseName: JsonFields.string(
        JsonFields.object(parent['phase'], 'parent.phase'),
        'name',
      ),
      citations: JsonFields.list(
        json,
        'citations',
      ).map(_citation).toList(growable: false),
    );
  }

  static String _slug(Map<String, Object?> json) {
    final slug = JsonFields.string(json, 'slug');
    if (!isValidSlug(slug)) {
      throw FormatException('Field "slug" must be a valid slug');
    }
    return slug;
  }

  static EventCitation _citation(Object? body) {
    final json = JsonFields.object(body, 'citation');
    final source = JsonFields.object(json['source'], 'citation.source');
    return EventCitation(
      locator: JsonFields.string(json, 'locator'),
      sourceTitle: JsonFields.string(source, 'title'),
      excerpt: JsonFields.optString(json, 'excerpt'),
      sourceAuthor: JsonFields.optString(source, 'author'),
    );
  }
}
