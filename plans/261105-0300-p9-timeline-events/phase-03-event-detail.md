---
status: completed
---

# Phase 3 - Chi tiết sự kiện + series liên quan (task 9.3)

## Files
- `app_router.dart`: route cấp trên cùng `AppRoutes.event` -> `EventDetailScreen(slug)`, ngoài `StatefulShellRoute` (như `/series/:slug`, thanh tab ẩn). Slug lấy từ `state.pathParameters`; kiểm tra bằng `isValidSlug` ở provider (đã có ở repo).
- Mới `lib/features/timeline/ui/`:
  - `event_detail_screen.dart`: `AppPage` + nút back; `CatalogAsyncView` trên `eventDetailProvider(slug)`; lỗi 404 hiện `CatalogError` có Thử lại (như màn Series).
  - `event_header.dart`: khối màu đầu trang (không có ảnh), đường dẫn "{periodName} / {phaseName}", nhãn thời gian, tên, tóm tắt.
  - `event_citations.dart`: tiêu đề "Nguồn tư liệu lịch sử"; mỗi nguồn: `sourceTitle` (1 dòng), `{sourceAuthor ?? l.eventSourceFallbackAuthor} · {locator}`; `excerpt` (nếu có) trong khối trích dẫn. Chỉ hiện phần khi `citations` không rỗng. Chuỗi ghép dùng ICU placeholder trong ARB, không nối chuỗi.
  - `event_related_series.dart`: `ref.watch(eventSeriesProvider(event.id))`: đang tải -> không hiện gì (không chặn trang); lỗi hoặc rỗng -> **ẩn** cả phần (lỗi ghi log ở repo); có -> tiêu đề "Podcast liên quan" + thẻ series dùng lại widget thẻ series có sẵn (`shared/widgets` hoặc `features/series`: kiểm trước; **không import chéo feature**, nếu thẻ nằm trong `features/series` thì chuyển lên `shared/widgets`). Bấm: `context.push(AppRoutes.seriesFor(slug))`.
- l10n (vi và en): `eventSourcesTitle`, `eventSourceFallbackAuthor` ("Tài liệu lịch sử", theo RN), `eventSourceLine` (placeholder author, locator), `eventRelatedTitle`. RN dùng "Chính sử" khi `locator` rỗng: parser đã bắt `locator` không rỗng nên không cần nhánh này, ghi trong ADR.

## Lệch RN có chủ ý
RN mở một series **cứng**. Flutter hiện series thật theo `eventId` và ẩn khi không có. Ghi vào ADR 0011.

## Xong khi
Bấm một hàng ở timeline mở chi tiết; chi tiết 404 có Thử lại; phần tư liệu và liên quan ẩn khi rỗng; `flutter analyze` sạch trong `lib/`, mỗi file <= 250 dòng, Verify rỗng.
