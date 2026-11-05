---
status: pending
---

# Phase 3 - Catalog + Player + Progress (11.1b)

## Files
- `test/shared/catalog/`: `catalog_parser` (series list/detail, episode detail, topics, periods, tìm kiếm `q`, "tạp mới"; trường thiếu/sai kiểu -> `FormatException`; cover `null`; item hỏng bị bỏ và ghi log), `CatalogRepository` qua Dio giả.
- `test/shared/audio/`: sửa `audio_view_model_test.dart`; `PlaybackRepository._parse` (id không khớp -> lỗi, `durationMs <= 0`, URL không phải https, `CONTENT_UNAVAILABLE`); `PlayedBitmap` (thứ tự bit LSB, kích thước `ceil(giây/8)`, base64, `mark` ngoài biên, `clear`, `isEmpty`); `ProgressSync` với `fake_async` hoặc `Timer` giả: không flush khi không "dirty", không đánh dấu khi seek (delta > 5s), tick lần đầu, `end()` chờ lần gửi đang chạy, 409 `AUDIO_CHANGED` tắt sync, 422 xoá bitmap, 429/mạng giữ dirty; `completion` gọi `onCompleted`; `rearm()` sau hoàn thành.
- Resume: vị trí local -> vị trí server -> 0, kẹp trong `duration - resumeEndMargin`, bỏ qua khi nhỏ hơn `resumeMinSeconds`.
- `PlaybackController` với `AudioPlayer` giả (override `audioPlayerProvider`): khách bấm Play -> chờ đăng nhập rồi phát lại trong TTL, hết TTL thì bỏ; đổi ngôi kể giữ vị trí; lỗi mở nguồn thử lại 1 lần.
- Cho `just_audio` không chạy được trên máy test thì dùng giả, không khởi tạo plugin thật.

## Ghi chú
Bitmap đối chiếu mẫu RN (`usePlayback.ts` ở `E:/FPT/Semester_8/WDP301/su-ky-project/apps/mobile/src/features/heritage-app/usePlayback.ts`): lấy một vector cố định (ví dụ giây 0, 1, 8, 9 đánh dấu -> byte đầu `0x03`, byte hai `0x03`) và so với kết quả tính tay theo công thức RN.

## Xong khi
`flutter test test/shared` xanh, analyze 0 lỗi trong phạm vi, report cập nhật.
