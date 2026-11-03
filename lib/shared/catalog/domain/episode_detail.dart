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
