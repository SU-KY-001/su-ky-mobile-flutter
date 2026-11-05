# Phase 3 - PlaybackController (tasks 4.3a, 4.3b, 4.6, 4.8)

Context: [plan.md](./plan.md). Cần phase 1 (hằng, init) và phase 2 (`episodeDetailProvider`, `PlaybackRepository`). Đọc `lib/features/auth/ui/session_controller.dart` (`SessionState.isAuthenticated`), `lib/shared/audio/audio_view_model.dart` (hành vi hẹn giờ/tốc độ cần giữ), `lib/core/di/providers.dart` (`sharedPreferencesProvider`). Phase này chưa sửa UI; `audio_view_model.dart` còn nguyên tới phase 4.

## Requirements
**Files** (`lib/shared/audio/`, mỗi file ≤ 250 dòng)
- `playback_state.dart`: bất biến + `copyWith`. `PlaybackState{episode: EpisodeDetail?, narrationId, status (idle|loading|ready|error), playing, completed, durationMs, speed, sleepEnabled, error: PlaybackError?}`; `enum PlaybackError {unavailable, network, player}`; `enum PlayOutcome {started, needsLogin, failed}`. Không import Flutter widgets.
- `playback_providers.dart`: `audioPlayerProvider` (`Provider<AudioPlayer>`, `ref.onDispose(player.dispose)`), `playbackPositionProvider` (`StreamProvider.autoDispose<Duration>` từ `player.positionStream`).
- `local_playback_store.dart`: bọc `SharedPreferences`: `position(narrationId)` / `savePosition(narrationId, seconds)` (khoá `pos.<narrationId>`), `lastEpisode()` / `saveLastEpisode(slug, narrationId)` / `clearLastEpisode()`. JSON `lastEpisode` giải mã từng trường tại ranh giới (kiểu và rỗng), sai → `null` + `AppLogger.error`, không throw. Mọi lỗi lưu → `StorageException`/log, không nuốt im.
- `playback_controller.dart`: `NotifierProvider<PlaybackController, PlaybackState>` (không `autoDispose`, xem plan quyết định 2) + `lastListenProvider` (`FutureProvider.autoDispose<LastListen?>` = `lastEpisode` + vị trí) để Home hiện "nghe tiếp".

**Hành vi**
- `Future<PlayOutcome> playEpisode(String slug, {String? narrationId})`: nếu `!sessionController.isAuthenticated` → `PlayOutcome.needsLogin` (chưa gọi mạng). Tăng `_loadToken`; mỗi `await` sau đó kiểm token, lệch thì bỏ kết quả (bấm nhanh nhiều tập). `status = loading` → `ref.read(episodeDetailProvider(slug).future)` → chọn narration `playableFor(narrationId)`; `null` → `error: unavailable`. → `_loadNarration(narration, startAt: restoredPosition)`.
- `_loadNarration`: `PlaybackRepository.playback(id)`; `Err` có `errorCode == 'CONTENT_UNAVAILABLE'` → `unavailable`, lỗi khác → `network`. `player.setAudioSource(AudioSource.uri(url, tag: MediaItem(...)), initialPosition: startAt)`; `PlayerException` → gọi lại `playback` **một lần** (URL có chữ ký có thể hết hạn) rồi nếu vẫn lỗi `error: player`; `PlayerInterruptedException` bỏ qua (có lần tải mới thay thế). Thành công: `setSpeed(state.speed)`, `saveLastEpisode`, `invalidate(lastListenProvider)`, xin quyền thông báo **một lần mỗi lần chạy app** (`requestNotificationPermission`, kết quả không chặn phát), rồi `play()`.
- Khôi phục vị trí (quy tắc RN): vị trí cục bộ hợp lệ nếu `> resumeMinSeconds` và `< duration - resumeEndMarginSeconds`, ngược lại 0.
- `togglePlayPause()`: đang phát thì `pause()` + lưu vị trí; hết tập (`completed`) thì `seek(0)` rồi `play()`. `restart()` = `seek(0)` + `play()`. `seekToRatio(double)`, `skip(int seconds)` (kẹp `[0, duration]`, bước dùng `AudioDefaults.seekStepSeconds`). Không có tập đang nạp thì bỏ qua.
- `switchNarration(String narrationId)` (4.3b): chỉ khi `episode.narrations` có narration `available` đó; lấy `player.position`, `_loadNarration(mới, startAt: min(position, durationMới - resumeEndMarginSeconds))`, giữ nguyên `playing`. Vị trí cục bộ của narration cũ được lưu trước khi đổi.
- `cycleSpeed()`: đi vòng `AudioDefaults.playbackSpeeds`, `player.setSpeed`. `toggleSleepTimer()`: bật `Timer(sleepTimerMinutes)` rồi `pause()` + tắt cờ; tắt thì huỷ. Huỷ timer khi controller dispose.
- Lưu vị trí cục bộ: nghe `positionStream`, ghi tối đa mỗi `localPositionSaveInterval` và chỉ khi `>= resumeMinSeconds`; ghi ngay khi pause; hết tập (`ProcessingState.completed`) ghi 0 và `completed = true`, `playing = false`.
- Đăng xuất (`ref.listen(sessionControllerProvider)` chuyển sang khách): `player.stop()`, trả state về rỗng, `clearLastEpisode()`, `invalidate(lastListenProvider)`.
- `pause()` công khai cho Quiz (`quiz_view_model.dart` gọi hiện nay).

## Risks / security
- Race: hai `playEpisode` chồng nhau hoặc `switchNarration` giữa lúc tải; token ở trên là cách chặn duy nhất; đừng dùng cờ bool.
- `Timer` hẹn giờ ngủ có thể không bắn khi Doze (chưa kiểm); ghi vào ADR.
- Không log URL, token, tên hay email; log lỗi kèm `narrationId`/`slug` (không phải PII) và cause/stack.
- Mỗi I/O có timeout: `dioProvider` đã đặt; `setAudioSource` bọc `.timeout(AudioDefaults.loadTimeout)` (thêm hằng 20 s) rồi map thành lỗi `network`.

## Todo
- [x] `PlaybackState`, enum lỗi/outcome
- [x] `audioPlayerProvider`, `playbackPositionProvider`
- [x] `LocalPlaybackStore` (vị trí + lastEpisode, parse từng trường)
- [x] `playEpisode`/`_loadNarration`/retry URL/token chống chồng
- [x] toggle, seek, skip, restart, switchNarration
- [x] tốc độ + hẹn giờ ngủ
- [x] đăng xuất dừng phát; `lastListenProvider`
- [x] `flutter analyze` sạch; không file > 250 dòng
