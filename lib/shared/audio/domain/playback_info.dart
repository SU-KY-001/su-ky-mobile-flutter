/// Streamable audio of one narration, as returned by the playback endpoint.
final class PlaybackInfo {
  const PlaybackInfo({
    required this.narrationId,
    required this.episodeId,
    required this.assetId,
    required this.url,
    required this.durationMs,
    required this.syncInterval,
    this.serverPositionMs,
  });

  final String narrationId;
  final String episodeId;

  /// Audio asset of this narration; the server rejects progress for old ones.
  final String assetId;

  /// Signed, short-lived https URL. Never log it.
  final Uri url;
  final int durationMs;

  /// How often progress is sent; clamped to `AudioDefaults.minSyncInterval`.
  final Duration syncInterval;

  /// Last position stored on the server, null when there is none.
  final int? serverPositionMs;
}
