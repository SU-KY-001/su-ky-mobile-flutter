import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

class AudioState {
  const AudioState({
    this.episode = 1,
    this.position = AppDesign.initialPosition,
    this.playing = false,
    this.favorite = false,
    this.saved = false,
    this.speed = 1.2,
    this.sleepEnabled = false,
  });
  final int episode;
  final int position;
  final bool playing;
  final bool favorite;
  final bool saved;
  final double speed;
  final bool sleepEnabled;
  int get duration => AppDesign.episodeSeconds[episode];
  double get progress => position / duration;
  AudioState copyWith({
    int? episode,
    int? position,
    bool? playing,
    bool? favorite,
    bool? saved,
    double? speed,
    bool? sleepEnabled,
  }) => AudioState(
    episode: episode ?? this.episode,
    position: position ?? this.position,
    playing: playing ?? this.playing,
    favorite: favorite ?? this.favorite,
    saved: saved ?? this.saved,
    speed: speed ?? this.speed,
    sleepEnabled: sleepEnabled ?? this.sleepEnabled,
  );
}

/// Shared in-memory playback demo. No device audio or network requests.
class AudioViewModel extends Notifier<AudioState> {
  Timer? _sleepTimer;
  @override
  AudioState build() {
    final ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.playing) return;
      final next = state.position + state.speed;
      state = state.copyWith(
        position: next.round().clamp(0, state.duration),
        playing: next < state.duration,
      );
    });
    ref.onDispose(() {
      ticker.cancel();
      _sleepTimer?.cancel();
    });
    return const AudioState();
  }

  void toggle() => state = state.copyWith(playing: !state.playing);
  void pause() => state = state.copyWith(playing: false);
  void playEpisode(int index) {
    if (index < 0 || index >= AppDesign.episodeSeconds.length) return;
    state = state.copyWith(
      episode: index,
      position: index == state.episode ? state.position : 0,
      playing: true,
    );
  }

  void startOver() =>
      state = state.copyWith(episode: 0, position: 0, playing: true);
  void seek(double progress) => state = state.copyWith(
    position: (progress.clamp(0, 1) * state.duration).round(),
  );
  void skip(int seconds) => state = state.copyWith(
    position: (state.position + seconds).clamp(0, state.duration),
  );
  void favorite() => state = state.copyWith(favorite: !state.favorite);
  void save() => state = state.copyWith(saved: !state.saved);
  void changeSpeed() =>
      state = state.copyWith(speed: state.speed >= 2 ? 1 : state.speed + 0.2);
  void sleep() {
    _sleepTimer?.cancel();
    final enabled = !state.sleepEnabled;
    state = state.copyWith(sleepEnabled: enabled);
    if (enabled) {
      _sleepTimer = Timer(
        const Duration(minutes: AppDesign.sleepMinutes),
        () => state = state.copyWith(playing: false, sleepEnabled: false),
      );
    }
  }
}

final audioViewModelProvider = NotifierProvider<AudioViewModel, AudioState>(
  AudioViewModel.new,
);

String audioTime(int seconds) =>
    '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
