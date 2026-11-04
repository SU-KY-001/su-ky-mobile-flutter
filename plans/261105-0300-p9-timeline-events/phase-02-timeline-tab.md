---
status: completed
---

# Phase 2 - Tab Lịch sử: pills thời kỳ + timeline dọc (task 9.2)

## Files
- Di chuyển `lib/features/home/ui/period_pills.dart` -> `lib/shared/widgets/period_pills.dart`; nhận `String? selected` và `ValueChanged<String?> onSelect`, vẫn đọc `periodsProvider`. Home truyền `homeViewModelProvider` của nó. **Cập nhật mọi nơi gọi** (không để bản cũ).
- Router:
  - `app_routes.dart`: `history = '/history'`, `event = '/events/:slug'`, `eventFor(slug)`.
  - `app_router.dart`: thêm `AppTab.history: GoRoute(path: AppRoutes.history, builder: ... TimelineScreen())` vào `tabRoutes` **ngay sau `discover`** (thứ tự map = thứ tự nhánh = thứ tự thanh tab; xem `main_navigation.dart`). Route chi tiết để phase 3.
- Mới `lib/features/timeline/ui/` (mỗi file một widget công khai, <= 250 dòng):
  - `timeline_screen.dart`: tiêu đề + phụ đề (l10n), `PeriodPills`, rồi `CatalogAsyncView<List<HistoricalEvent>>` trên `eventsProvider(selectedPeriod)`. Rỗng: tiêu đề "Chưa có sự kiện trong thời kỳ này" + gợi ý chọn "Tất cả". Lỗi: `CatalogError` có Thử lại (invalidate provider).
  - `timeline_view_model.dart`: `TimelineViewModel extends Notifier<String?>` autoDispose; `select(String? periodId)`.
  - `timeline_entry.dart`: một hàng: cột trái 60 dp (đường dọc 2 dp, nút tròn 14 dp, nhãn thời gian `timeLabel` bỏ "Khoảng "; mục đầu tô màu nhấn, mục sau viền đồng; đường cụt ở mục đầu và cuối), thẻ phải (khối màu thay ảnh, tiêu đề tối đa 2 dòng, tóm tắt tối đa 2 dòng, mũi tên). Bấm cả thẻ: `context.push(AppRoutes.eventFor(slug))`.
- Màu/kích thước: hằng có tên trong `timeline_colors.dart` hoặc `AppDesign` (không `Color(0x..)` ngoài chỗ cho phép, không số trần). Khối thay ảnh dùng `colorScheme`.
- l10n (vi **và** en): `timelineTitle`, `timelineSubtitle`, `timelineEmptyTitle`, `timelineEmptyMessage`; dùng lại `tabHistory`, `homeAllPeriods`. Gỡ key `timeline` cũ nếu không còn ai dùng (grep trước).
- Chọn thời kỳ -> `eventsProvider` đổi tham số -> tải lại; trong lúc tải hiện loading của `CatalogAsyncView` (RN cũng vậy).

## Xong khi
Tab xuất hiện thứ hai trên thanh; `flutter gen-l10n` chạy được; `flutter analyze` sạch trong `lib/`; 3 lệnh Verify của `AGENTS.md` rỗng; Home vẫn dùng pills qua widget chung.
