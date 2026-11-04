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
  });

  final String episodeSlug;
  final String episodeTitle;
  final String seriesTitle;

  /// False when the episode or its series is no longer published.
  final bool available;
  final String narrationId;

  /// Rounded percentage in `[0, 100]`.
  final int percent;

  /// Fraction in `[0, 1]` for a progress bar.
  double get progress => percent / historyPercentMax;
}

final class ListeningHistory {
  const ListeningHistory({required this.items});

  final List<HistoryEntry> items;
}
