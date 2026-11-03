# Phase 2 - Repo PUT + bộ lập lịch sync (tasks 5.2, 5.3)

## Files
- Sửa `lib/shared/audio/data/playback_repository.dart`: thêm `Future<Result<ProgressUpdate>> updateProgress(...)`
- Thêm `lib/shared/audio/domain/progress_update.dart`: `ProgressUpdate{ completion: ListeningCompletion? }`, `ListeningCompletion{ xpAwarded, totalXp }`. Bỏ `missions[]` của phản hồi (P7 lấy lại từ `GET /api/me/weekly-missions`, không consumer ở đây).
- Thêm `lib/shared/audio/progress_sync.dart`: lớp `ProgressSync` (không `part`).
- Sửa `lib/shared/audio/playback_controller.dart` (244/250 dòng!) và `playback_controller_lifecycle.dart` (72 dòng).

## Repo
`PUT /api/me/listening-progress/{narrationId}` body `{assetId, positionMs, playedBitmap}`; `Options(sendTimeout/receiveTimeout = AudioDefaults.progressTimeout)` (hằng số tên, 10 s); parse phản hồi từng trường (`completion` null hoặc map có `xpAwarded`, `totalXp` int). Lỗi map qua `mapDioException` hiện có (`ApiException.errorCode` đã có 409/422/429).

## `ProgressSync`
Phụ thuộc: repo, `PlayedBitmap`, hàm `bool Function() isSignedIn`, callback `void Function(ListeningCompletion) onCompleted`, `AppLogger`.
- `begin(PlaybackInfo info)`: khởi tạo bitmap mới, `previous = null`, `dirty = false`, `disabled = false`; bật `Timer.periodic(info.syncInterval, (_) => flush())`.
- `onPosition(Duration pos, {required bool playing})`: nếu `!playing` hoặc `isSignedIn() == false` thì `previous = pos` và thoát. Nếu `previous != null` và `0 < delta <= maxTickDeltaSeconds`: `mark` mọi giây từ `floor(previous)` đến `floor(pos)-1`, `dirty = true`. Cập nhật `previous`.
- `onSeek()`: `previous = null` (giây bị nhảy qua không được đánh dấu; khớp RN). **Không flush.**
- `flush({bool force = false})`: bỏ nếu `disabled`, `saving`, `!dirty` hoặc chưa đăng nhập. `saving = true`; gửi `positionMs = lastPosition.inMilliseconds`; thành công: `dirty = false`, nếu `completion != null` gọi `onCompleted`; lỗi: 409 `AUDIO_CHANGED` → `disabled = true` + log; 422 `PROGRESS_INVALID` → `bitmap.clear(); dirty = false` + log; còn lại giữ `dirty` (thử lại tick sau) + log nguyên nhân. `finally saving = false`. Không bao giờ throw ra UI.
- `end()`: `await flush()` rồi huỷ timer (dùng khi đổi ngôi kể, dừng, hết bài, `ref.onDispose`).

## Nối controller (ít dòng nhất có thể)
- `_onPosition` hiện có (đăng ký ở `build()` dòng ~57) → gọi thêm `_sync.onPosition(pos, playing: state.playing)`.
- `_onPlayerState`: khi `playing` chuyển `false` (tạm dừng) → `_sync.flush()`; khi `ProcessingState.completed` → `await _sync.end()` trước khi xoá trạng thái.
- `seekToRatio`, `skip`: gọi `_sync.onSeek()` sau khi seek.
- `switchNarration`, `_stopAndClear`, `ref.onDispose`: `await _sync.end()`; sau khi tải playback mới gọi `_sync.begin(info)`.
- Nếu `playback_controller.dart` vượt 250 dòng: chuyển một method nhỏ đã có (ví dụ `_stopAndClear`) sang `playback_controller_lifecycle.dart` thay vì dồn thêm vào file chính.
- Provider `progressSyncProvider` không cần; `PlaybackController` tạo `ProgressSync` trong `build()` với `ref.read(playbackRepositoryProvider)` và `ref.read(signedInProvider)`.

## Xong khi
`flutter analyze` sạch; file nào cũng <= 250 dòng; không `catch` nuốt lỗi (mọi nhánh lỗi ghi log có nguyên nhân + stack).
