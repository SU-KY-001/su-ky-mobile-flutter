/// Playback behavior constants shared by the playback controller and player UI.
abstract final class AudioDefaults {
  static const seekStepSeconds = 15;
  static const sleepTimerMinutes = 15;

  static const notificationChannelId = 'su_ky.playback';

  /// Speeds the player cycles through; the first entry equal to 1.0 is default.
  static const playbackSpeeds = <double>[0.75, 1.0, 1.25, 1.5, 2.0];
  static const defaultSpeed = 1.0;

  /// A guest's Play request survives login only for this long.
  static const pendingPlayTtl = Duration(minutes: 10);

  static const localPositionSaveInterval = Duration(seconds: 3);
  static const loadTimeout = Duration(seconds: 20);
  static const progressTimeout = Duration(seconds: 10);

  /// Progress is sent no more often than this, whatever the server asks.
  static const minSyncInterval = Duration(seconds: 5);

  /// Larger position jumps count as a seek and mark no seconds.
  static const maxTickDeltaSeconds = 5;

  /// Saved position is restored only when inside (min, duration - margin).
  static const resumeMinSeconds = 1;
  static const resumeEndMarginSeconds = 2;
}
