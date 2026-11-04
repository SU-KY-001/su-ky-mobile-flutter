# 0007 — Listening progress sync

Signed-in playback uploads progress with
`PUT /api/me/listening-progress/{narrationId}`. `ProgressSync`
(`lib/shared/audio/progress_sync.dart`) owns the played bitmap, the timer and
the error policy; `PlaybackController` only forwards player events.

- **Bitmap.** `PlayedBitmap` is pure Dart (`dart:convert`, no package): one bit
  per second, LSB first, standard base64 with padding. `totalSeconds` is
  `ceil(durationMs / 1000)`; marks outside it are ignored, so a seek cannot
  write past the end.
- **Only this session's bits are sent.** The server OR-merges monotonically
  (under a row lock), so re-uploading bits it already has just spends the
  anti-cheat budget (`ceil(elapsed * 2) + 30` new bits). The server bitmap in
  `progress.playedBitmap` is therefore not loaded back.
- **Marking follows RN.** A position tick marks the seconds between the
  previous and current position only when `0 < delta <= 5 s`; a seek resets the
  reference, so jumped-over seconds stay unplayed. Nothing is marked while
  paused or signed out.
- **Cadence.** `max(5 s, sync.intervalMs)` from the playback payload, plus a
  flush on pause (only when dirty), on completion, on narration switch, on stop
  and on dispose. Seeks do not flush: repeated seeking would hit the 20/60 s
  rate limit.
- **Errors.** 409 `AUDIO_CHANGED` disables sync for the loaded narration until
  the next playback load (logged, no retry). 422 `PROGRESS_INVALID` clears the
  current bitmap and keeps playing. 429, 5xx and network errors keep the dirty
  flag for the next tick. Nothing is thrown to the UI.
- **Resume** is local → server → zero. A position is valid only inside
  `(1 s, duration - 2 s)`; one helper guards both tiers. Narration switches
  still clamp the current position into the new audio.
- **Completion** is server-owned: threshold, XP and mission progress. Only the
  `completion` object of the PUT response is mapped, and its arrival bumps
  `learningActivityProvider` (`lib/core/activity/learning_activity.dart`). The
  provider lives in `core` so audio produces it and P7's missions consume it
  without importing another feature; P7 is its first consumer, recorded here
  because the provider has no consumer before then.
- **`ProgressSync` is a separate class, not a `part`**, because
  `playback_controller.dart` is at the 250-line limit. Moving one method per
  concern keeps both files inside the limit.
- **No `Idempotency-Key`.** The API merges progress monotonically per narration
  and accepts a repeated body.

Not verified yet: a real PUT, the 409/422/429 branches against the live API,
and a bitmap sample compared with RN. Deferred to P11, like the rest of the
audio runtime checks.
