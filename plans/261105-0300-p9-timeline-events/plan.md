---
title: "P9 - Tab Lịch sử (dòng thời gian) + Chi tiết sự kiện"
description: "Tab Lịch sử với pills thời kỳ và timeline dọc từ /api/historical-events; màn chi tiết sự kiện có tư liệu trích dẫn và các series liên quan. Giống RN, không thêm tính năng."
status: completed
priority: P2
effort: 2d
branch: dev
tags: [feature, frontend, catalog]
blockedBy: []
blocks: []
created: 2026-11-05
---

# P9 - Tab Lịch sử + Chi tiết sự kiện

Nguồn: report mục P9, 3 scout (API, RN, code Flutter) và 4 lần GET thật ngày 2026-11-05. P3 (catalog) đã `completed` nên không bị chặn. Không có plan nào đang mở. **Không test, không emulator** (gom vào P11).

## Hợp đồng API đã xác minh (GET công khai, không cần đăng nhập)
- `GET /api/historical-periods` -> đã có parser (`HistoricalPeriod`: id, slug, name, startYear, endYear).
- `GET /api/historical-events?page=1&limit=50[&periodId=uuid]` -> `{items[], page, limit, total}`. `limit` tối đa 50. Thật: **9 sự kiện / 5 thời kỳ**, nên **không phân trang** (một trang, `limit` là hằng số có tên). Server đã sắp xếp theo năm.
- Mỗi item: `id, slug, name, summary, time{...}, timeLabel, parent{period{id,name}, phase{id,name}}, reviewedAt, citations[]`.
  - `timeLabel` là chuỗi server đã định dạng ("938", "1258 – 1288", "Khoảng 500 TCN – Khoảng 111 TCN"). **Dùng nguyên chuỗi này**, không parse `time` (năm âm, `approximate`, `RANGE/POINT/UNKNOWN`). RN bỏ "Khoảng " ở nhãn trục thời gian; giữ hành vi đó.
  - `citations[]`: `{locator, excerpt|null, source{id, title, author|null, ...}}`. Chỉ dùng `locator`, `excerpt`, `source.title`, `source.author`.
  - **Không có trường ảnh bìa.** RN dùng ảnh dự phòng cục bộ theo slug; Flutter không có ảnh sự kiện, dùng khối màu (xem phase 2).
- `GET /api/historical-events/{slug}` -> một item đầy đủ như trên. Slug lạ/chưa công khai: `404 NOT_FOUND` ("Sự kiện chưa công khai").
- `GET /api/series?eventId={uuid}` -> `{items,page,limit,total}`; đã thử: có sự kiện trả 1 series, có sự kiện trả 0. RN không dùng endpoint này (nút "Khám phá podcast liên quan" mở một slug **cứng**). Flutter dùng `eventId` để khỏi hard-code; sự kiện không có series thì **ẩn** phần liên quan.

## Quyết định
1. **Bỏ 9.0a/9.0b (mock trước).** Dữ liệu thật dựng được ngay; mock sẽ phải viết rồi xoá. Quy ước "x.0 dựng mock" của report không được áp dụng cho P9, và ghi rõ trong report.
2. **Giống RN, không thêm:** không zoom/kéo timeline, không cây nhánh, không nút chia sẻ (RN để rỗng), không ô tìm kiếm trên header (RN để rỗng), không deep link từ Home.
3. **Bộ lọc thời kỳ có state riêng** (`Notifier<String?>` autoDispose của tab Lịch sử), không dùng chung với Home. `PeriodPills` hiện gắn cứng vào `homeViewModelProvider`: chuyển lên `lib/shared/widgets/period_pills.dart`, nhận `selected` và `onSelect`; Home và Lịch sử cùng dùng (DRY, 1 widget).
4. **Dữ liệu sự kiện nằm trong `lib/shared/catalog`** cùng `CatalogRepository`, theo ADR 0005. `catalog_parser.dart` đang 194 dòng: thêm parser sự kiện vào file mới `historical_event_parser.dart`, không phình file cũ.
5. **Danh sách sự kiện: một dòng hỏng bị bỏ qua và ghi log** (như lịch phát hành P8); phản hồi thiếu `items` thì cả yêu cầu lỗi. **Chi tiết: lỗi từng trường là lỗi cả yêu cầu.**
6. **Tab Lịch sử không cần đăng nhập**; chi tiết sự kiện cũng vậy (route công khai). Không thêm guard.
7. **Route chi tiết `/events/:slug` nằm ngoài shell**, giống `/series/:slug`, để ẩn thanh tab như RN.

## Phase
| # | Phase | Kết quả | Trạng thái |
|---|---|---|---|
| 1 | [phase-01-domain-repo.md](phase-01-domain-repo.md) | domain, parser, repo, providers | completed |
| 2 | [phase-02-timeline-tab.md](phase-02-timeline-tab.md) | `PeriodPills` dùng chung, tab Lịch sử, timeline dọc | completed |
| 3 | [phase-03-event-detail.md](phase-03-event-detail.md) | màn chi tiết, tư liệu, series liên quan | completed |
| 4 | [phase-04-tests-docs.md](phase-04-tests-docs.md) | tài liệu (test để P11) | completed |

## Rủi ro / chưa kiểm
- Chưa chạy trên emulator; chưa thấy màn thật.
- Dữ liệu thật chỉ 9 sự kiện: bố cục khi có nhiều (vài chục) chưa kiểm; vượt 50 thì sự kiện thứ 51 trở đi **không hiện** (giới hạn đã biết, ghi ADR).
- `reviewedAt`, `time`, `phase` của thời kỳ và `source.tier/url/file` bị bỏ có chủ ý.
- Series liên quan chỉ có 1 sự kiện trong 2 sự kiện đã thử; chưa quét hết 9 sự kiện.
