---
status: completed
---

# Phase 3 - Màn Lịch phát sóng (task 8.3)

## 3.1 Route
- `app_routes.dart`: `static const schedule = '/schedule';`.
- `app_router.dart`: `GoRoute(path: AppRoutes.schedule, builder: ... const ScheduleScreen())` **ngoài** shell (RN ẩn thanh tab ở màn này), **không** authGuard (API công khai).

## 3.2 Dữ liệu (`lib/features/schedule/`)
- `domain/release.dart`: `Release { id, title, scheduledAt (UTC), released, episodeSlug, seriesTitle }`.
- `data/schedule_repository.dart`: `abstract ScheduleRepository { Future<Result<List<Release>>> month(DateTime monthStart); }` + `ApiScheduleRepository(Dio)`. `GET /api/showcase/releases?from=&to=` với `from` = đầu tháng địa phương `.toUtc().toIso8601String()`, `to` = đầu tháng sau (quyết định 6). Parse từng trường; item hỏng bỏ qua + log; thiếu `items` → `FormatException`. Cùng khuôn `_guard` như phase 1. Hằng số đường dẫn tên có nghĩa.
- `data/schedule_providers.dart`: `scheduleRepositoryProvider`, `scheduleProvider = FutureProvider.autoDispose.family<List<Release>, DateTime>` (khoá = đầu tháng).

## 3.3 UI (`lib/features/schedule/ui/`)
- `schedule_view_model.dart`: `Notifier<DateTime>` autoDispose, state = đầu tháng đang xem (khởi tạo: tháng hiện tại), `previous()` / `next()`. Không `setState`.
- `schedule_screen.dart`: `AppPage`, nút back (`context.popOrGo(AppRoutes.profile)`), bộ chuyển tháng (chevron trái/phải + nhãn tháng bằng `DateFormat.yMMMM(locale)` hoặc ICU ARB), `CatalogAsyncView<List<Release>>`: loading, lỗi + thử lại (`ref.invalidate(scheduleProvider(month))`), trống "Chưa có lịch phát trong tháng này".
- `release_tile.dart` (một widget công khai): ngày giờ (`intl` theo locale), tiêu đề tập, series, nhãn `Đã phát hành` / `Sắp ra mắt` (màu qua `colorScheme`/`schedule_colors.dart`), nút nghe chỉ khi `released` → `playFromUi(context, ref, release.episodeSlug)`.
- Sắp xếp theo `scheduledAt` tăng dần (API không đảm bảo thứ tự).

## ARB (vi VÀ en)
`scheduleTitle` ("Lịch phát sóng"), `scheduleEmpty`, `scheduleReleased`, `scheduleUpcoming`, `schedulePrevMonth`/`scheduleNextMonth` (tooltip + semantics). Không literal trong `.dart`.

## Xong khi
`flutter analyze` sạch trong `lib/`, mọi file ≤ 250 dòng, 3 lệnh Verify rỗng, chuông ở Hồ sơ mở được màn.
