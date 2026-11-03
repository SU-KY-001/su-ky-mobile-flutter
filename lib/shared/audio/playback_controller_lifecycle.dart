part of 'playback_controller.dart';

void _onPlayerState(PlaybackController c, PlayerState playerState) {
  if (c.playbackState.status != PlaybackStatus.ready) return;
  if (playerState.processingState == ProcessingState.completed) {
    c.updatePlaybackState(
      c.playbackState.copyWith(playing: false, completed: true),
    );
    final id = c.playbackState.narrationId;
    if (id != null) unawaited(c._store.savePosition(id, 0));
    unawaited(c._player.pause());
    return;
  }
  if (playerState.playing != c.playbackState.playing) {
    c.updatePlaybackState(
      c.playbackState.copyWith(playing: playerState.playing, completed: false),
    );
  }
}

void _onPosition(PlaybackController c, Duration position) {
  final id = c.playbackState.narrationId;
  if (id == null || !c.playbackState.playing) return;
  final now = DateTime.now();
  if (now.difference(c._lastSave) < AudioDefaults.localPositionSaveInterval) {
    return;
  }
  if (position.inSeconds < AudioDefaults.resumeMinSeconds) return;
  c._lastSave = now;
  unawaited(c._store.savePosition(id, position.inSeconds));
}

Future<void> _persistPosition(PlaybackController c) async {
  final id = c.playbackState.narrationId;
  if (id == null) return;
  final seconds = c.playbackState.completed ? 0 : c._player.position.inSeconds;
  if (c.playbackState.completed || seconds >= AudioDefaults.resumeMinSeconds) {
    await c._store.savePosition(id, seconds);
  }
}

Future<void> _askNotificationPermissionOnce(PlaybackController c) async {
  if (c._askedNotifications) return;
  c._askedNotifications = true;
  await requestNotificationPermission();
}

void _onSignedInChanged(PlaybackController c, bool? previous, bool signedIn) {
  if (signedIn) {
    final pending = c._pending;
    c._pending = null;
    if (pending == null) return;
    final fresh =
        DateTime.now().difference(pending.requestedAt) <=
        AudioDefaults.pendingPlayTtl;
    if (fresh) {
      unawaited(c.playEpisode(pending.slug, narrationId: pending.narrationId));
    }
    return;
  }
  unawaited(_stopAndClear(c));
}

Future<void> _stopAndClear(PlaybackController c) async {
  c._loadToken++;
  c._pending = null;
  c._sleepTimer?.cancel();
  await c._player.stop();
  c.updatePlaybackState(PlaybackState(speed: c.playbackState.speed));
  await c._store.clearLastEpisode();
  c.providerRef.invalidate(lastListenProvider);
}
