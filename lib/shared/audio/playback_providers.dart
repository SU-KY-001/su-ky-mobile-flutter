import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'local_playback_store.dart';

/// The one player of the app. Tests override it with a fake.
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(player.dispose);
  return player;
});

/// Playback position, kept out of the controller state so the seek bar can
/// rebuild every tick without rebuilding the whole screen.
final playbackPositionProvider = StreamProvider.autoDispose<Duration>(
  (ref) => ref.watch(audioPlayerProvider).positionStream,
);

/// Last episode for the Home "continue listening" card (null for none).
final lastListenProvider = Provider.autoDispose<LastListen?>(
  (ref) => ref.watch(localPlaybackStoreProvider).lastEpisode(),
);
