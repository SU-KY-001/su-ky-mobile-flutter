# 0006 — Audio playback

Podcast audio plays through `just_audio` with `just_audio_background` (it wraps
`audio_service`), so playback continues with the screen off and the system
notification has controls. No custom `AudioHandler`. Versions are pinned in
`pubspec.lock`.

- **One player, one controller.** `audioPlayerProvider` owns the only
  `AudioPlayer`; `PlaybackController` (`lib/shared/audio/`) is its only user.
  The controller is deliberately not `autoDispose`: the mini-player and
  background playback outlive every screen. The seek position is a separate
  `StreamProvider` so the ticking bar does not rebuild whole screens.
- **One entry point.** Every Play button calls `playFromUi` →
  `PlaybackController.playEpisode(slug)`. It loads `GET /api/episodes/{slug}`
  (cached 60 s), picks the requested or first available narration, then calls
  `GET /api/narrations/{id}/playback` (never cached: `no-store`, signed URL)
  and opens the source. A newer request supersedes an older one through a load
  token. A failing source is retried once with a fresh playback URL.
- **Guests** get `PlayOutcome.needsLogin`, a dialog, then `/login`. The request
  is kept in memory as `pendingPlay` and replayed when the session becomes
  signed-in within `AudioDefaults.pendingPlayTtl`; it is dropped on sign-out or
  on another Play. Unlike RN, it expires, so a late sign-in does not start audio
  unexpectedly. `shared` reads the session through `signedInProvider`
  (`core/auth`), overridden in `main`, so it never imports a feature.
- **Local memory** (`LocalPlaybackStore`, SharedPreferences): resume position
  per narration and the last episode. Restore only when the saved second is in
  `(resumeMinSeconds, duration - resumeEndMarginSeconds)`. Signing out stops
  playback and clears the last episode. Nothing is sent to the server yet.
- **Narration switch** keeps the position (RN restarts at 0), clamped inside the
  new audio.
- **Speed and sleep timer** are local: `AudioDefaults.playbackSpeeds`, a `Timer`.
- **Notification permission** (Android 13+) is requested once per run through a
  small `MethodChannel` in `MainActivity` instead of a permission plugin.
  Denial still allows playback.
- No favorites/bookmarks (the API has none). The Player hides its quiz button
  until quiz is rebuilt on slugs (P6).

Not verified yet (no data or no run): seeking on the signed Cloudinary URLs, a
second narration of one episode, the sleep timer under Doze, Android 17
foreground-service behavior. Tests are deferred to P11 and the existing audio
tests are stale.
