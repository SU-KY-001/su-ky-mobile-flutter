---
status: completed
---

# Phase 1 - Domain + parser + repo + providers (task 9.1)

## Files
- Mới `lib/shared/catalog/domain/historical_event.dart` (Dart thuần, `final`, bất biến):
  - `HistoricalEvent{id, slug, name, summary, timeLabel, periodName, phaseName, citations}`. Một model dùng cho cả danh sách và chi tiết (server trả cùng shape), không tách hai lớp.
  - `EventCitation{locator, excerpt?, sourceTitle, sourceAuthor?}`.
  - `EventsPage`: không cần; repo trả `List<HistoricalEvent>` (không phân trang, xem plan).
- Mới `lib/shared/catalog/data/historical_event_parser.dart`: `HistoricalEventParser.list(Object? body)` (bỏ dòng hỏng + `AppLogger.error`, thiếu `items` ném `FormatException`) và `.detail(Object? body)` (nghiêm ngặt). Dùng lại các helper `_string/_object/_list` đang có trong `catalog_parser.dart`: nếu chúng là private, **chuyển thành public dùng chung** trong cùng thư mục thay vì chép (không thêm bản sao thứ sáu).
  - Bắt buộc: `id, slug, name, summary, timeLabel` (chuỗi không rỗng), `parent.period.name`, `parent.phase.name`. `citations` bắt buộc là mảng; `excerpt` và `source.author` cho phép `null`.
  - `slug` phải qua `isValidSlug` đang có.
- Sửa `lib/shared/catalog/data/catalog_repository.dart` (181 dòng, thêm ~40; còn dưới 250):
  - `Future<Result<List<HistoricalEvent>>> events({String? periodId})`: `GET /api/historical-events` với `page=1`, `limit=CatalogDefaults.eventsLimit`, `periodId` khi có.
  - `Future<Result<HistoricalEvent>> eventDetail(String slug)`: slug sai -> `Err(ApiException 404 NOT_FOUND)` như `seriesDetail`.
  - `listSeries` thêm tham số `String? eventId` (query `eventId`).
- Sửa `lib/shared/catalog/catalog_constants.dart`: `eventsLimit = 50`, tên cho đường dẫn nếu repo đang đặt hằng ở file đó.
- Sửa `lib/shared/catalog/data/catalog_providers.dart`:
  - `eventsProvider` = `FutureProvider.autoDispose.family<List<HistoricalEvent>, String?>` (`periodId`), `cacheFor(staleTime)`.
  - `eventDetailProvider` = family theo `slug`.
  - `eventSeriesProvider` = family theo `eventId` -> `listSeries(eventId:).items`.
- Mọi gọi qua `_guard` sẵn có (timeout, map lỗi, log). Không nuốt lỗi.

## Xong khi
`flutter analyze` sạch trong `lib/`; file nào cũng <= 250 dòng; chưa có UI nào dùng.
