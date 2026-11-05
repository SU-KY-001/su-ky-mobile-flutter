import 'episode.dart';

final class SeriesSummary {
  const SeriesSummary({
    required this.id,
    required this.slug,
    required this.title,
    required this.episodeCount,
    this.description,
    this.startYear,
    this.endYear,
    this.coverUrl,
    this.landscapeUrl,
    this.publishedAt,
  });

  final String id;
  final String slug;
  final String title;
  final String? description;
  final int? startYear;
  final int? endYear;
  final String? coverUrl;
  final String? landscapeUrl;
  final int episodeCount;
  final DateTime? publishedAt;
}

final class SeriesDetail {
  const SeriesDetail({
    required this.id,
    required this.slug,
    required this.title,
    required this.episodes,
    this.description,
    this.creatorName,
    this.startYear,
    this.endYear,
    this.coverUrl,
    this.landscapeUrl,
  });

  final String id;
  final String slug;
  final String title;
  final String? description;
  final String? creatorName;
  final int? startYear;
  final int? endYear;
  final String? coverUrl;
  final String? landscapeUrl;
  final List<EpisodeSummary> episodes;

  /// First episode that has playable audio, in server order.
  EpisodeSummary? get firstPlayableEpisode {
    for (final episode in episodes) {
      if (episode.playable != null) return episode;
    }
    return null;
  }

  /// Total listening time of the playable narrations, rounded to minutes.
  int get totalMinutes {
    var ms = 0;
    for (final episode in episodes) {
      ms += episode.playable?.durationMs ?? 0;
    }
    return (ms / Duration.millisecondsPerMinute).round();
  }
}
