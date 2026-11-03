import '../domain/episode.dart';
import '../domain/episode_detail.dart';
import '../domain/historical_period.dart';
import '../domain/paged.dart';
import '../domain/series.dart';

/// Validates server JSON field by field; the raw map never leaves this file.
/// Every parse function throws [FormatException] naming the bad field.
abstract final class CatalogParser {
  static Paged<SeriesSummary> seriesPage(Object? body) {
    final json = _object(body, 'series page');
    return Paged(
      items: _list(json, 'items').map(_seriesSummary).toList(growable: false),
      page: _int(json, 'page'),
      limit: _int(json, 'limit'),
      total: _int(json, 'total'),
    );
  }

  static SeriesDetail seriesDetail(Object? body) {
    final json = _object(body, 'series detail');
    return SeriesDetail(
      id: _string(json, 'id'),
      slug: _string(json, 'slug'),
      title: _string(json, 'title'),
      description: _optString(json, 'description'),
      creatorName: _creatorName(json),
      startYear: _optInt(json, 'startYear'),
      endYear: _optInt(json, 'endYear'),
      coverUrl: _imageUrl(json, 'cover'),
      landscapeUrl: _imageUrl(json, 'coverLandscape'),
      episodes: _list(json, 'episodes').map(_episode).toList(growable: false),
    );
  }

  static EpisodeDetail episodeDetail(Object? body) {
    final json = _object(body, 'episode detail');
    final series = _object(json['series'], 'series');
    final hasQuiz = json['hasQuiz'];
    if (hasQuiz is! bool) {
      throw const FormatException('Field "hasQuiz" must be a bool');
    }
    return EpisodeDetail(
      id: _string(json, 'id'),
      slug: _string(json, 'slug'),
      title: _string(json, 'title'),
      description: _optString(json, 'description'),
      seriesSlug: _string(series, 'slug'),
      seriesTitle: _string(series, 'title'),
      seriesCoverUrl: _imageUrl(series, 'cover'),
      narrations: _list(
        json,
        'narrations',
      ).map(_narration).toList(growable: false),
      previous: _link(json, 'previousEpisode'),
      next: _link(json, 'nextEpisode'),
      hasQuiz: hasQuiz,
    );
  }

  static EpisodeLink? _link(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) return null;
    final link = _object(value, key);
    return EpisodeLink(
      id: _string(link, 'id'),
      slug: _string(link, 'slug'),
      title: _string(link, 'title'),
    );
  }

  static List<HistoricalPeriod> periods(Object? body) {
    final json = _object(body, 'periods');
    return _list(json, 'items')
        .map((item) {
          final period = _object(item, 'period');
          return HistoricalPeriod(
            id: _string(period, 'id'),
            slug: _string(period, 'slug'),
            name: _string(period, 'name'),
            startYear: _optInt(period, 'startYear'),
            endYear: _optInt(period, 'endYear'),
          );
        })
        .toList(growable: false);
  }

  static SeriesSummary _seriesSummary(Object? item) {
    final json = _object(item, 'series');
    return SeriesSummary(
      id: _string(json, 'id'),
      slug: _string(json, 'slug'),
      title: _string(json, 'title'),
      description: _optString(json, 'description'),
      startYear: _optInt(json, 'startYear'),
      endYear: _optInt(json, 'endYear'),
      coverUrl: _imageUrl(json, 'cover'),
      landscapeUrl: _imageUrl(json, 'coverLandscape'),
      episodeCount: _int(json, 'episodeCount'),
      publishedAt: _optDate(json, 'publishedAt'),
    );
  }

  static EpisodeSummary _episode(Object? item) {
    final json = _object(item, 'episode');
    return EpisodeSummary(
      id: _string(json, 'id'),
      slug: _string(json, 'slug'),
      title: _string(json, 'title'),
      description: _optString(json, 'description'),
      publishedAt: _optDate(json, 'publishedAt'),
      posterUrl: _imageUrl(json, 'poster'),
      sortOrder: _int(json, 'sortOrder'),
      narrations: _list(
        json,
        'narrations',
      ).map(_narration).toList(growable: false),
    );
  }

  static Narration _narration(Object? item) {
    final json = _object(item, 'narration');
    final available = json['available'];
    if (available is! bool) {
      throw const FormatException('Field "available" must be a bool');
    }
    return Narration(
      id: _string(json, 'id'),
      type: switch (_string(json, 'type')) {
        'FIRST_PERSON' => NarrationType.firstPerson,
        'THIRD_PERSON' => NarrationType.thirdPerson,
        final other => throw FormatException('Unknown narration type: $other'),
      },
      available: available,
      durationMs: _optInt(json, 'durationMs'),
    );
  }

  static String? _creatorName(Map<String, Object?> json) {
    final creator = json['creator'];
    if (creator == null) return null;
    return _optString(_object(creator, 'creator'), 'name');
  }

  /// `{url}` or null. An empty URL counts as no image.
  static String? _imageUrl(Map<String, Object?> json, String key) {
    final image = json[key];
    if (image == null) return null;
    return _optString(_object(image, key), 'url');
  }

  static Map<String, Object?> _object(Object? value, String what) {
    if (value is Map<String, Object?>) return value;
    throw FormatException('Expected $what to be an object');
  }

  static List<Object?> _list(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is List<Object?>) return value;
    throw FormatException('Field "$key" must be a list');
  }

  static String _string(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
    throw FormatException('Field "$key" must be a non-empty string');
  }

  static String? _optString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! String) {
      throw FormatException('Field "$key" must be a string');
    }
    return value.isEmpty ? null : value;
  }

  static int _int(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is int) return value;
    throw FormatException('Field "$key" must be an int');
  }

  static int? _optInt(Map<String, Object?> json, String key) =>
      json[key] == null ? null : _int(json, key);

  static DateTime? _optDate(Map<String, Object?> json, String key) {
    final value = _optString(json, key);
    if (value == null) return null;
    final date = DateTime.tryParse(value);
    if (date == null) throw FormatException('Field "$key" must be a date');
    return date;
  }
}
