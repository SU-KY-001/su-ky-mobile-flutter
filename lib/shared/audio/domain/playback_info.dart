/// Streamable audio of one narration, as returned by the playback endpoint.
final class PlaybackInfo {
  const PlaybackInfo({
    required this.narrationId,
    required this.episodeId,
    required this.url,
    required this.durationMs,
  });

  final String narrationId;
  final String episodeId;

  /// Signed, short-lived https URL. Never log it.
  final Uri url;
  final int durationMs;
}
