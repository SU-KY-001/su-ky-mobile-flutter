# Phase 3 - Resume 3 tầng + tín hiệu completion (tasks 5.4, 5.5)

## Files
- Sửa `lib/shared/audio/playback_controller_loading.dart` (126 dòng), hàm `_startPosition` (~dòng 103-117)
- Thêm `lib/core/activity/learning_activity.dart`
- Sửa nơi tạo `ProgressSync` trong `PlaybackController.build()` (phase 2)

## 5.4 Resume
Thứ tự: `saved = _store.position(narrationId)` hợp lệ (`> resumeMinSeconds` và `< duration - resumeEndGuardSeconds`; hai hằng này đã có hoặc thêm vào `AudioDefaults`, mặc định 1 và 2 như RN) → ngược lại `info.serverPositionMs` cùng điều kiện → ngược lại 0. Hiện P4 chỉ có tầng local; thêm tầng server, gộp điều kiện hợp lệ thành một hàm `_validResume(seconds, duration)` để hai tầng dùng chung.

## 5.5 Completion
`lib/core/activity/learning_activity.dart`: `final learningActivityProvider = NotifierProvider<LearningActivity, int>(LearningActivity.new)`; `build() => 0`; `void bump() => state++`. Đây là bộ đếm sự kiện "người dùng vừa làm xong một hoạt động học" (hoàn thành tập, sau này đạt quiz ở P6). Nằm ở `core` để `shared/audio` (producer) và `features/weekly_missions`/profile (consumer, P7/P8) đều dùng được mà không import chéo.
`onCompleted` của `ProgressSync` → `ref.read(learningActivityProvider.notifier).bump()` và `ref.invalidate(...)` các cache catalog cần làm mới nếu có (hiện chưa có consumer nào phụ thuộc trạng thái hoàn thành tập; không thêm invalidate thừa).
Consumer đầu tiên là P7 (`weeklyMissionsProvider` watch provider này); ADR 0007 phải ghi rõ điều này (quy tắc "provider không consumer" trong `AGENTS.md`).

## Xong khi
`flutter analyze` sạch; grep `learningActivityProvider` chỉ thấy producer (P5), consumer thêm ở P7.
