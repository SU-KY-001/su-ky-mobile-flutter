enum NarrationType { firstPerson, thirdPerson }

/// One audio version of an episode. [available] means the audio is ready to
/// stream (server rule), not merely that a record exists.
final class Narration {
  const Narration({
    required this.id,
    required this.type,
    required this.available,
    this.durationMs,
  });

  final String id;
  final NarrationType type;
  final bool available;
  final int? durationMs;
}

final class EpisodeSummary {
  const EpisodeSummary({
    required this.id,
    required this.slug,
    required this.title,
    required this.sortOrder,
    required this.narrations,
    this.description,
    this.publishedAt,
    this.posterUrl,
  });

  final String id;
  final String slug;
  final String title;
  final String? description;
  final DateTime? publishedAt;
  final String? posterUrl;
  final int sortOrder;
  final List<Narration> narrations;

  /// First narration that can be played, or null when none is ready.
  Narration? get playable {
    for (final narration in narrations) {
      if (narration.available) return narration;
    }
    return null;
  }
}

/// An episode together with the series it belongs to.
final class LatestEpisode {
  const LatestEpisode({
    required this.seriesSlug,
    required this.seriesTitle,
    required this.episode,
  });

  final String seriesSlug;
  final String seriesTitle;
  final EpisodeSummary episode;
}
