import '../domain/episode.dart';
import '../domain/episode_detail.dart';
import '../domain/historical_period.dart';
import '../domain/paged.dart';
import '../domain/series.dart';
import 'json_fields.dart';

/// Validates server JSON field by field; the raw map never leaves this file.
/// Every parse function throws [FormatException] naming the bad field.
abstract final class CatalogParser {
  static Paged<SeriesSummary> seriesPage(Object? body) {
    final json = JsonFields.object(body, 'series page');
    return Paged(
      items: JsonFields.list(
        json,
        'items',
      ).map(_seriesSummary).toList(growable: false),
      page: JsonFields.integer(json, 'page'),
      limit: JsonFields.integer(json, 'limit'),
      total: JsonFields.integer(json, 'total'),
    );
  }

  static SeriesDetail seriesDetail(Object? body) {
    final json = JsonFields.object(body, 'series detail');
    return SeriesDetail(
      id: JsonFields.string(json, 'id'),
      slug: JsonFields.string(json, 'slug'),
      title: JsonFields.string(json, 'title'),
      description: JsonFields.optString(json, 'description'),
      creatorName: _creatorName(json),
      startYear: JsonFields.optInteger(json, 'startYear'),
      endYear: JsonFields.optInteger(json, 'endYear'),
      coverUrl: _imageUrl(json, 'cover'),
      landscapeUrl: _imageUrl(json, 'coverLandscape'),
      episodes: JsonFields.list(
        json,
        'episodes',
      ).map(_episode).toList(growable: false),
    );
  }

  static EpisodeDetail episodeDetail(Object? body) {
    final json = JsonFields.object(body, 'episode detail');
    final series = JsonFields.object(json['series'], 'series');
    final hasQuiz = json['hasQuiz'];
    if (hasQuiz is! bool) {
      throw const FormatException('Field "hasQuiz" must be a bool');
    }
    return EpisodeDetail(
      id: JsonFields.string(json, 'id'),
      slug: JsonFields.string(json, 'slug'),
      title: JsonFields.string(json, 'title'),
      description: JsonFields.optString(json, 'description'),
      seriesSlug: JsonFields.string(series, 'slug'),
      seriesTitle: JsonFields.string(series, 'title'),
      seriesCoverUrl: _imageUrl(series, 'cover'),
      publishedAt: JsonFields.optDate(json, 'publishedAt'),
      seriesStartYear: JsonFields.optInteger(series, 'startYear'),
      seriesEndYear: JsonFields.optInteger(series, 'endYear'),
      event: _eventRef(series),
      sources: _sources(series),
      narrations: JsonFields.list(
        json,
        'narrations',
      ).map(_narration).toList(growable: false),
      previous: _link(json, 'previousEpisode'),
      next: _link(json, 'nextEpisode'),
      hasQuiz: hasQuiz,
    );
  }

  /// Decorative: a malformed event is dropped so it can never block playback.
  static EpisodeEventRef? _eventRef(Map<String, Object?> series) {
    try {
      final value = series['historicalEvent'];
      if (value == null) return null;
      final event = JsonFields.object(value, 'historicalEvent');
      return EpisodeEventRef(
        slug: JsonFields.string(event, 'slug'),
        name: JsonFields.string(event, 'name'),
      );
    } on FormatException {
      return null;
    }
  }

  /// Decorative: malformed entries are skipped, the rest are kept. A source
  /// link is kept only when it is an absolute https URL.
  static List<EpisodeSource> _sources(Map<String, Object?> series) {
    final items = series['sources'];
    if (items is! List<Object?>) return const [];
    final sources = <EpisodeSource>[];
    for (final item in items) {
      try {
        final source = JsonFields.object(item, 'source');
        final url = JsonFields.optString(source, 'url');
        sources.add(
          EpisodeSource(
            title: JsonFields.string(source, 'title'),
            publisher: JsonFields.optString(source, 'publisher'),
            url: url != null && Uri.tryParse(url)?.scheme == 'https'
                ? url
                : null,
          ),
        );
      } on FormatException {
        continue;
      }
    }
    return sources;
  }

  static EpisodeLink? _link(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) return null;
    final link = JsonFields.object(value, key);
    return EpisodeLink(
      id: JsonFields.string(link, 'id'),
      slug: JsonFields.string(link, 'slug'),
      title: JsonFields.string(link, 'title'),
    );
  }

  static List<HistoricalPeriod> periods(Object? body) {
    final json = JsonFields.object(body, 'periods');
    return JsonFields.list(json, 'items')
        .map((item) {
          final period = JsonFields.object(item, 'period');
          return HistoricalPeriod(
            id: JsonFields.string(period, 'id'),
            slug: JsonFields.string(period, 'slug'),
            name: JsonFields.string(period, 'name'),
            startYear: JsonFields.optInteger(period, 'startYear'),
            endYear: JsonFields.optInteger(period, 'endYear'),
          );
        })
        .toList(growable: false);
  }

  static SeriesSummary _seriesSummary(Object? item) {
    final json = JsonFields.object(item, 'series');
    return SeriesSummary(
      id: JsonFields.string(json, 'id'),
      slug: JsonFields.string(json, 'slug'),
      title: JsonFields.string(json, 'title'),
      description: JsonFields.optString(json, 'description'),
      startYear: JsonFields.optInteger(json, 'startYear'),
      endYear: JsonFields.optInteger(json, 'endYear'),
      coverUrl: _imageUrl(json, 'cover'),
      landscapeUrl: _imageUrl(json, 'coverLandscape'),
      episodeCount: JsonFields.integer(json, 'episodeCount'),
      publishedAt: JsonFields.optDate(json, 'publishedAt'),
    );
  }

  static EpisodeSummary _episode(Object? item) {
    final json = JsonFields.object(item, 'episode');
    return EpisodeSummary(
      id: JsonFields.string(json, 'id'),
      slug: JsonFields.string(json, 'slug'),
      title: JsonFields.string(json, 'title'),
      description: JsonFields.optString(json, 'description'),
      publishedAt: JsonFields.optDate(json, 'publishedAt'),
      posterUrl: _imageUrl(json, 'poster'),
      sortOrder: JsonFields.integer(json, 'sortOrder'),
      narrations: JsonFields.list(
        json,
        'narrations',
      ).map(_narration).toList(growable: false),
    );
  }

  static Narration _narration(Object? item) {
    final json = JsonFields.object(item, 'narration');
    final available = json['available'];
    if (available is! bool) {
      throw const FormatException('Field "available" must be a bool');
    }
    return Narration(
      id: JsonFields.string(json, 'id'),
      type: switch (JsonFields.string(json, 'type')) {
        'FIRST_PERSON' => NarrationType.firstPerson,
        'THIRD_PERSON' => NarrationType.thirdPerson,
        final other => throw FormatException('Unknown narration type: $other'),
      },
      available: available,
      durationMs: JsonFields.optInteger(json, 'durationMs'),
    );
  }

  static String? _creatorName(Map<String, Object?> json) {
    final creator = json['creator'];
    if (creator == null) return null;
    return JsonFields.optString(JsonFields.object(creator, 'creator'), 'name');
  }

  /// `{url}` or null. An empty URL counts as no image.
  static String? _imageUrl(Map<String, Object?> json, String key) {
    final image = json[key];
    if (image == null) return null;
    return JsonFields.optString(JsonFields.object(image, key), 'url');
  }
}
