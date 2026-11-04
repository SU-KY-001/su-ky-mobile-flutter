/// The server's answer to a progress update.
final class ProgressUpdate {
  const ProgressUpdate({this.completion});

  /// Non-null only on the update that crossed the completion threshold.
  final ListeningCompletion? completion;
}

/// One-time completion reward for an episode.
final class ListeningCompletion {
  const ListeningCompletion({required this.xpAwarded, required this.totalXp});

  final int xpAwarded;
  final int totalXp;
}
