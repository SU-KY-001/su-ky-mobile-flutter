import '../catalog/domain/episode_detail.dart';
import 'audio_defaults.dart';

enum PlaybackStatus { idle, loading, ready, error }

enum PlaybackError { unavailable, network, player }

/// Result of asking to play an episode.
enum PlayOutcome { started, needsLogin, failed }

/// The last episode a play was requested for, so the player can retry it.
final class PlayRequest {
  const PlayRequest({required this.slug, this.narrationId});

  final String slug;
  final String? narrationId;
}

/// Immutable view of the single app-wide player.
final class PlaybackState {
  const PlaybackState({
    this.episode,
    this.narrationId,
    this.status = PlaybackStatus.idle,
    this.playing = false,
    this.completed = false,
    this.durationMs = 0,
    this.speed = AudioDefaults.defaultSpeed,
    this.sleepEnabled = false,
    this.error,
    this.request,
  });

  final EpisodeDetail? episode;
  final String? narrationId;
  final PlaybackStatus status;
  final bool playing;

  /// Playback reached the end; Play restarts from zero.
  final bool completed;
  final int durationMs;
  final double speed;
  final bool sleepEnabled;
  final PlaybackError? error;

  /// The episode last requested, kept for retrying a failed load.
  final PlayRequest? request;

  /// The mini-player shows once an episode was chosen.
  bool get hasEpisode => episode != null;

  PlaybackState copyWith({
    EpisodeDetail? episode,
    String? narrationId,
    PlaybackStatus? status,
    bool? playing,
    bool? completed,
    int? durationMs,
    double? speed,
    bool? sleepEnabled,
    PlaybackError? error,
    PlayRequest? request,
    bool clearError = false,
  }) => PlaybackState(
    episode: episode ?? this.episode,
    narrationId: narrationId ?? this.narrationId,
    status: status ?? this.status,
    playing: playing ?? this.playing,
    completed: completed ?? this.completed,
    durationMs: durationMs ?? this.durationMs,
    speed: speed ?? this.speed,
    sleepEnabled: sleepEnabled ?? this.sleepEnabled,
    error: clearError ? null : (error ?? this.error),
    request: request ?? this.request,
  );
}
