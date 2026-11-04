/// One scheduled episode release from the public showcase calendar.
final class Release {
  const Release({
    required this.id,
    required this.title,
    required this.scheduledAt,
    required this.released,
    required this.episodeSlug,
    required this.seriesTitle,
  });

  final String id;
  final String title;

  /// Always UTC.
  final DateTime scheduledAt;
  final bool released;
  final String episodeSlug;
  final String seriesTitle;
}
