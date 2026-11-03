part of 'playback_controller.dart';

/// A guest's Play request, replayed once they sign in (within a TTL).
final class _PendingPlay {
  _PendingPlay(this.slug, this.narrationId) : requestedAt = DateTime.now();

  final String slug;
  final String? narrationId;
  final DateTime requestedAt;
}

bool _isLoaded(PlaybackController c, String slug, String? narrationId) =>
    c.playbackState.status == PlaybackStatus.ready &&
    c.playbackState.episode?.slug == slug &&
    (narrationId == null || narrationId == c.playbackState.narrationId);

PlayOutcome _settle(PlaybackController c, int token, _OpenResult result) =>
    switch (result) {
      _OpenResult.opened => PlayOutcome.started,
      _OpenResult.superseded => PlayOutcome.started,
      _OpenResult.unavailable => c._fail(token, PlaybackError.unavailable),
      _OpenResult.network => c._fail(token, PlaybackError.network),
      _OpenResult.player => c._fail(token, PlaybackError.player),
    };

void _onPlayerState(PlaybackController c, PlayerState playerState) {
  if (c.playbackState.status != PlaybackStatus.ready) return;
  if (playerState.processingState == ProcessingState.completed) {
    unawaited(_finishPlayback(c));
    return;
  }
  if (playerState.playing != c.playbackState.playing) {
    c.updatePlaybackState(
      c.playbackState.copyWith(playing: playerState.playing, completed: false),
    );
    if (!playerState.playing) unawaited(c._sync.flush());
  }
}

Future<void> _finishPlayback(PlaybackController c) async {
  await c._sync.end();
  c.updatePlaybackState(
    c.playbackState.copyWith(playing: false, completed: true),
  );
  final id = c.playbackState.narrationId;
  if (id != null) unawaited(c._store.savePosition(id, 0));
  unawaited(c._player.pause());
}

void _onPosition(PlaybackController c, Duration position) {
  c._sync.onPosition(position, playing: c.playbackState.playing);
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
  await c._sync.end();
  await c._player.stop();
  c.updatePlaybackState(PlaybackState(speed: c.playbackState.speed));
  await c._store.clearLastEpisode();
  c.providerRef.invalidate(lastListenProvider);
}
