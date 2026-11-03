---
title: "P3 - Catalog (khách duyệt series/tập/thời kỳ thật)"
description: "Tầng catalog dùng chung (DTO + repository + provider), tab Podcast, chi tiết Series, Khám phá theo thời kỳ, Tìm kiếm thật; thay mock catalog."
status: completed
priority: P1
effort: 4d
branch: dev
tags: [feature, frontend, api, catalog]
blockedBy: [261104-2100-p2-app-shell]
blocks: []
created: 2026-11-04
---

# P3 - Catalog

Nguồn: report mục P3 (tasks 3.0–3.6), scout API (zod `packages/shared` + gọi GET công khai), scout RN, scout code Flutter. **Không test, không emulator ở P3** (gom vào P11). Mốc = `dart format`, `flutter analyze` sạch trong `lib/`, 3 lệnh grep/find "Verify" rỗng.
Chờ P2: cần `AppTab`/bản đồ tab + `routerProvider` để thêm tab Podcast.

## Hợp đồng API đã xác minh (khách gọi được, đều 200 không cần đăng nhập)
Envelope phân trang `{items,page,limit,total}` (mặc định `limit=20`, tối đa 50). Nguồn: `packages/shared/src/schemas/*.ts`.
| Endpoint | Dùng cho | Trường dùng |
|---|---|---|
| `GET /api/series?page&limit&q&periodId` | carousel, Home, Search | `id, slug, title, description?, startYear?, endYear?, cover{url}?, coverLandscape{url}?, episodeCount, publishedAt?` |
| `GET /api/series/{slug}` | chi tiết, tập mới | thêm `creator{name}?`, `episodes[{id,slug,title,description?,publishedAt?,poster{url}?,sortOrder,narrations[{id,type FIRST_PERSON/THIRD_PERSON,durationMs?,available}]}]` |
| `GET /api/historical-periods` | pills thời kỳ | `items[{id,slug,name,startYear?,endYear?}]` (bỏ `phases`) |
Lỗi: `404 NOT_FOUND` (slug sai), `400 BAD_REQUEST`. Dữ liệu thật hiện có: 4 series, **`cover` và `coverLandscape` đều `null`** ⇒ bắt buộc có ảnh dự phòng cục bộ (RN chọn theo hash slug, `podcastApi.ts:175-188`). Không có endpoint danh sách tập (`/api/episodes` → 404, đã gọi thử).
Chưa kiểm: `periodId` hợp lệ có trả series không (gọi thử với UUID rỗng trả 200); dữ liệu period thật chưa xem hết.

## Quyết định (lệch so với report, cần bạn biết)
1. **Bỏ 3.2 khỏi P3**: repo episode detail (`/api/episodes/{slug}`) và `/api/topics` **không có consumer** trong P3 (`AGENTS.md`: provider không consumer thì gỡ). Episode detail chuyển sang P4.2 (next/prev, narrations cho Player); topics sang P6.1 (lọc quiz). Cần sửa report.
2. **Gộp 3.0 vào 3.3**: endpoint công khai nên dựng UI thẳng trên model domain + provider thật, không dựng mock rồi thay.
3. **Tầng catalog đặt ở `lib/shared/catalog/{domain,data}`**: Podcast, Series, Search, Home đều dùng; feature không được import nội bộ feature khác (`AGENTS.md`). Tiền lệ: `shared/audio`.
4. **Không thêm `cached_network_image`**: `Image.network` + `errorBuilder` + ảnh dự phòng; hiện mọi cover là `null` nên gói chưa có việc để làm. Thêm khi dữ liệu có ảnh thật (ghi ADR).
5. **Tìm kiếm chỉ `q`** (RN chưa làm tìm kiếm thật): bỏ chip thời kỳ, "tìm gần đây", "xoá lịch sử", "tập liên quan" của mock. Nếu muốn giữ chip thời kỳ trong Search, bảo mình (API đã hỗ trợ `periodId`, ~nửa ngày).
6. **Chi tiết series không có nút quiz** cho tới P6 (không có `hasQuiz` ở danh sách tập; route quiz còn `int`). Nút quiz từng tập trong mock bị gỡ.
7. **"Tập mới phát hành" là N+1 có chặn** (đã chốt 2026-11-04: **không viết `/api/episodes`**, dùng đúng cách RN `podcastApi.latestEpisodes`): lấy 6 series đầu rồi `GET /api/series/{slug}` song song, gộp, lọc tập có audio, sắp `publishedAt` giảm, lấy 6. Cache 60s; khác RN ở chỗ series nào lỗi thì ghi log và bỏ qua, **tất cả** lỗi mới báo lỗi.
8. **Cache và retry theo RN** (`staleTime` 60s; retry tối đa 2, chỉ lỗi mạng/5xx/mã retryable, không retry 4xx): `Ref.cacheFor(catalogStaleTime)` và `ProviderScope(retry: appRetry)`. **Riverpod 3 tự retry mọi lỗi provider (tối đa 10 lần, lũy thừa) nếu không cấu hình**: bắt buộc đặt `retry`.
9. **Sources/`evidenceWarning` không parse** (RN không hiển thị ở chi tiết series; chưa có consumer).
10. Nút Phát và chạm tập vẫn đẩy sang `/player` dùng audio **mock** tới P4 (tạm; Player hiển thị tập mock). Link từ Player sang series dùng `MockCatalog.featuredSeriesSlug` (slug sống đã xác nhận) tới P4.4.

## Phase
| Phase | Tên | Trạng thái |
|-------|-----|-----------|
| 1 | [Catalog domain + data + providers + retry/cache](./phase-01-catalog-data.md) | Done |
| 2 | [Ảnh mạng + ảnh dự phòng](./phase-02-network-image.md) | Done |
| 3 | [Tab Podcast](./phase-03-podcast-tab.md) | Done |
| 4 | [Chi tiết Series (route `:slug`)](./phase-04-series-detail.md) | Done |
| 5 | [Khám phá (Home) theo thời kỳ](./phase-05-home-discover.md) | Done |
| 6 | [Tìm kiếm thật](./phase-06-search.md) | Done |
| 7 | [ADR catalog](./phase-07-adr.md) | Done |

Thứ tự bắt buộc 1 → 2 → 3 → 4 → 5 → 6 → 7 (3 dùng `latestEpisodesProvider` ở 1 và ảnh ở 2; 4 dùng route; 5 và 6 dùng provider + `CoverArt` mới).

## Test cũ sẽ vỡ (để P11)
`test/widget_test.dart:58-64` (chữ series mock), `:73-76` (rỗng search), `:123-131` (precache asset); `test/features/search/search_view_model_test.dart:11-13`; `test/features/home/home_view_model_test.dart:1-21`. Widget test chạm mạng phải override `catalogRepositoryProvider` (và `Image.network` cần `HttpOverrides` hoặc luôn truyền URL `null`).

## Rủi ro
- N+1 "tập mới" tăng độ trễ lần đầu (6 request song song) và số lần gọi API; cache 60s giảm nhẹ.
- `Image.network` không có cache đĩa; chấp nhận vì chưa có ảnh thật.
- Slug đi vào URL từ deep link: kiểm tra mẫu `[a-z0-9-]+` trước khi gọi API.
- Không có test: lỗi parse DTO chỉ lộ ở P11.3 (script gọi API thật).

## Ngoài phạm vi
Episode detail, topics, sources/bằng chứng, quiz CTA, tìm kiếm theo thời kỳ/gợi ý, tab Lịch sử và Quiz (P9, P6), phát audio thật (P4), cache đĩa/offline.
