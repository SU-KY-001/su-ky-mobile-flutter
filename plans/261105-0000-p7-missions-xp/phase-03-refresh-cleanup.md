---
status: completed
---

# Phase 3 - Làm mới tự động + dọn Vinh danh (tasks 7.2, 7.3)

## 7.2 Làm mới
`weeklyMissionsProvider` đã `ref.watch(learningActivityProvider)` (phase 1) nên mỗi `bump()` làm nó tải lại. Producer:
- P5: `ProgressSync.onCompleted` đã `bump()` (khi `completion != null`).
- P6 (đã xong): sau nộp quiz với `isPassed == true` gọi `ref.read(learningActivityProvider.notifier).bump()` trong `QuizViewModel`; luôn `invalidate(quizCatalogProvider)`. Đã đóng 7.2.
Không có polling.

## 7.3 Xoá (đã tra tham chiếu)
Xoá file:
- `lib/features/weekly_missions/ui/honours_screen.dart`, `honours_badge_card.dart`, `honours_medallion.dart`, `honours_milestone.dart`, `honours_statistics.dart`
- `lib/features/weekly_missions/ui/mission_detail_screen.dart`, `mission_detail_challenge_card.dart`, `mission_detail_next_card.dart`, và `mission_condition.dart` nếu không còn consumer sau phase 2
- `lib/features/weekly_missions/data/mock_missions.dart`; `domain/mission.dart` (thay bằng `shared/missions/domain`)
- `test/features/weekly_missions/ui/mission_detail_screen_test.dart` (kiểm tra code đã xoá; xoá không phải viết test)
Sửa:
- `lib/app/router/app_routes.dart`: bỏ `honours`, `missionDetail`
- `lib/app/router/app_router.dart`: bỏ 2 import và 2 route (dòng ~13-14, 85-91)
- `lib/l10n/app_vi.arb`, `app_en.arb`: xoá toàn bộ key `honours*` và key chỉ dùng cho chi tiết/streak/điểm danh; chạy `flutter gen-l10n` rồi `flutter analyze` để bắt key còn dùng (không xoá theo cảm giác, theo kết quả grep từng key).
- `grep -rn "mission_detail\|honours\|missionDetail\|MockMissions\|MissionKind" lib test` phải rỗng (trừ test mission khác sẽ sửa ở P11).

## Xong khi
`dart format lib`, `flutter analyze` sạch trong `lib/`, 3 lệnh Verify của `AGENTS.md` rỗng, `flutter gen-l10n` chạy được.
