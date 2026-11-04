# Phase 1 - Bitmap + mô hình playback (task 5.1)

## Files
- Thêm `lib/shared/audio/domain/played_bitmap.dart`
- Sửa `lib/shared/audio/domain/playback_info.dart`
- Sửa `lib/shared/audio/data/playback_repository.dart` (`_parse`, ~100 dòng hiện tại)

## Việc
1. `PlayedBitmap` thuần Dart (không import Flutter): 
   - `PlayedBitmap(int durationMs)`: `Uint8List(ceil(ceil(durationMs/1000)/8))`.
   - `void mark(int second)`: bỏ qua nếu ngoài `[0, totalSeconds)`; `bits[second >> 3] |= 1 << (second & 7)`.
   - `bool get isEmpty`; `String toBase64()` dùng `base64Encode` (chuẩn, có padding); `void clear()`.
   - Hằng số tên: không có số ma thuật (8 là cố định theo định nghĩa bit, đặt `_bitsPerByte`).
2. `PlaybackInfo` thêm: `assetId` (String), `syncInterval` (Duration, đã kẹp `>= AudioDefaults.minSyncInterval`), `serverPositionMs` (int?, từ `progress.positionMs`, null cho khách). **Không** giữ `completionThreshold` (server quyết, không consumer) và `playedBitmap` server (không nạp lại, xem plan quyết định 2).
3. `_parse`: đọc `audio.assetId` (bắt buộc, UUID chuỗi không rỗng), `sync.intervalMs` (int, thiếu thì lỗi parse → `AppException` như các trường khác của repo), `progress` null hoặc map có `positionMs` int >= 0; trường sai kiểu thì coi `progress` là null và ghi log (không làm hỏng phát).
4. `AudioDefaults` (đã có `resumeMinSeconds`): thêm `minSyncInterval = Duration(seconds: 5)`, `maxTickDeltaSeconds = 5` (RN `delta <= 5`).

## Xong khi
`flutter analyze` sạch; mọi chỗ dựng `PlaybackInfo` (grep `PlaybackInfo(`) đã cập nhật.
