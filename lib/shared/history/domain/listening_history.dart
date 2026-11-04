/// Progress capped at 100 percent. The API sends a decimal percentage.
const historyPercentMax = 100.0;

/// One episode in the signed-in user's listening history.
final class HistoryEntry {
  const HistoryEntry({
    required this.episodeSlug,
    required this.episodeTitle,
    required this.seriesTitle,
    required this.available,
    required this.narrationId,
    required this.percent,
    required this.isCompleted,
    required this.lastListenedAt,
  });

  final String episodeSlug;
  final String episodeTitle;
  final String seriesTitle;

  /// False when the episode or its series is no longer published.
  final bool available;
  final String narrationId;

  /// Rounded percentage in `[0, 100]`.
  final int percent;
  final bool isCompleted;

  /// Always UTC.
  final DateTime lastListenedAt;

  /// Fraction in `[0, 1]` for a progress bar.
  double get progress => percent / historyPercentMax;
}

final class ListeningHistory {
  const ListeningHistory({required this.items, required this.total});

  final List<HistoryEntry> items;

  /// Total entries the server holds, not just [items].
  final int total;
}
