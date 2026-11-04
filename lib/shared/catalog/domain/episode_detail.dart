import 'episode.dart';

/// Neighbouring episode of the same series (title + slug only).
final class EpisodeLink {
  const EpisodeLink({
    required this.id,
    required this.slug,
    required this.title,
  });

  final String id;
  final String slug;
  final String title;
}

/// Historical event the episode's series is about; links to the event page.
final class EpisodeEventRef {
  const EpisodeEventRef({required this.slug, required this.name});

  final String slug;
  final String name;
}

/// One cited source of the episode's series. [url] is optional metadata.
final class EpisodeSource {
  const EpisodeSource({required this.title, this.publisher, this.url});

  final String title;
  final String? publisher;
  final String? url;
}

/// One episode with everything the player needs.
final class EpisodeDetail {
  const EpisodeDetail({
    required this.id,
    required this.slug,
    required this.title,
    required this.seriesSlug,
    required this.seriesTitle,
    required this.narrations,
    required this.hasQuiz,
    this.description,
    this.seriesCoverUrl,
    this.publishedAt,
    this.seriesStartYear,
    this.seriesEndYear,
    this.event,
    this.sources = const [],
    this.previous,
    this.next,
  });

  final String id;
  final String slug;
  final String title;
  final String? description;
  final String seriesSlug;
  final String seriesTitle;
  final String? seriesCoverUrl;
  final DateTime? publishedAt;
  final int? seriesStartYear;
  final int? seriesEndYear;
  final EpisodeEventRef? event;
  final List<EpisodeSource> sources;
  final List<Narration> narrations;
  final EpisodeLink? previous;
  final EpisodeLink? next;
  final bool hasQuiz;

  List<Narration> get availableNarrations =>
      narrations.where((n) => n.available).toList(growable: false);

  /// The narration with [preferredId] when playable, else the first playable.
  Narration? playableFor(String? preferredId) {
    final available = availableNarrations;
    for (final narration in available) {
      if (narration.id == preferredId) return narration;
    }
    return available.isEmpty ? null : available.first;
  }
}
