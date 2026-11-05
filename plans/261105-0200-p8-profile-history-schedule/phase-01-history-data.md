---
status: completed
---

# Phase 1 - Domain + repo + provider lịch sử nghe (task 8.2a)

## Files (mới, `lib/shared/history/`)
- `domain/listening_history.dart`: Dart thuần, `final`:
  - `HistoryEntry { episodeSlug, episodeTitle, seriesTitle, available, narrationId, percent (int, đã clamp 0..100, làm tròn), isCompleted, lastListenedAt }`.
  - `ListeningHistory { items, total }`.
- `data/history_repository.dart`: `abstract HistoryRepository { Future<Result<ListeningHistory>> recent(); }` + `ApiHistoryRepository(Dio)`. Chép khuôn `shared/missions/data/weekly_missions_repository.dart` (`_guard` catch: `DioException` → `mapDioException`, `AppException`, `FormatException` → log + `UnknownException`, catch-all log).
  - `GET /api/me/listening-history` với `page=1`, `limit=historyLimit`, `status=all` (hằng số tên có nghĩa ở đầu file; **không** số trần).
  - Parse từng trường (object → `items` list → từng item): `episode.slug/title` chuỗi không rỗng, `episode.series.title`, `episode.available` bool, `lastNarrationId` UUID chuỗi, `percent` là `num` (clamp), `lastListenedAt` ISO. Item hỏng: bỏ qua + `AppLogger.error` (một dòng hỏng không làm sập cả danh sách); thiếu `items` → `FormatException`.
- `history_providers.dart`: `historyRepositoryProvider` (đọc `dioProvider`), `listeningHistoryProvider` = `FutureProvider.autoDispose<ListeningHistory?>`: `ref.watch(signedInProvider)` false → `null` (khách không gọi API); `ref.watch(learningActivityProvider)` để làm mới khi nghe xong tập/đạt quiz; lỗi → `AsyncError` (chép cách `weeklyMissionsProvider` ở `shared/missions/missions_providers.dart`).

## Lưu ý
- `shared/history` không import `features/`. Mỗi file ≤ 250 dòng.
- Đối xứng đăng xuất: provider phụ thuộc `signedInProvider` nên tự đổi sang `null`.

## Xong khi
`flutter analyze` sạch trong `lib/`; chưa có UI nào dùng.
