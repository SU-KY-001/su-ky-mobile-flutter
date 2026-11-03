# Phase 1 - Domain + repo + provider (task 7.1a)

## Files (mới)
- `lib/shared/missions/domain/weekly_missions.dart`: 
  - `enum MissionActivity { completeEpisode, passQuiz }`, `enum MissionStatus { inProgress, completed, expired }`.
  - `class WeeklyMission` (immutable: `id, title, activity, targetCount, progressCount, xpReward, status`; getter `progress` = `(progressCount/targetCount).clamp(0,1)`, 0 khi `targetCount == 0`).
  - `class WeeklyMissions { totalXp, weekEnd (DateTime, UTC), items }`; getter `completedCount`.
  Thuần Dart, không Flutter/Icon/Color.
- `lib/shared/missions/data/weekly_missions_repository.dart`: abstract + `ApiWeeklyMissionsRepository(Dio)`; `Future<Result<WeeklyMissions>> fetch()` gọi `GET /api/me/weekly-missions` (không gửi `weekStartDate`); parse từng trường (id/title string không rỗng, các số int >= 0, `weekEndDate` ISO), bỏ item lạ + `AppLogger` cảnh báo kèm giá trị; thiếu `items`/`totalXp` → `ApiException`/lỗi parse theo mẫu `catalog` repo. Timeout mặc định của `createDio`.
- `lib/shared/missions/missions_providers.dart`: `weeklyMissionsRepositoryProvider`; `weeklyMissionsProvider = FutureProvider.autoDispose<WeeklyMissions?>`: `ref.watch(signedInProvider)` false → `null` (không gọi API); `ref.watch(learningActivityProvider)` để làm mới (phase 3 xác nhận). Lỗi → `AsyncError` mang `AppException` để UI hiện thông báo + nút thử lại.

## Việc
Theo đúng mẫu `lib/shared/catalog/{domain,data}` và `appRetry` có sẵn. Mục `learningActivityProvider` chỉ có sau P5 — vì vậy plan chặn bởi P5.

## Xong khi
`flutter analyze` sạch; `lib/shared/missions` không import `features/` hay `flutter/`.
