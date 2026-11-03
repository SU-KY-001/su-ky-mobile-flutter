# Phase 3 - Tab Podcast (tasks 3.0 + 3.3)

Context: [plan.md](./plan.md). Cần phase 1-2 và `AppTab`/bản đồ tab từ P2. Chưa có mock tab này; dựng thẳng trên provider thật.

## Requirements
Nguồn UX: RN `PodcastScreens.tsx:35-150`.
- `lib/features/podcast/ui/podcast_screen.dart` (`ConsumerWidget`, không state riêng → không cần view model), nội dung cuộn dọc:
  1. **Banner nổi bật**: series có `slug == featuredSeriesSlug`, nếu không có thì series đầu của `seriesListProvider(null)`. Chạm → `context.push(AppRoutes.seriesFor(slug))`.
  2. **Carousel "Series lịch sử"**: cuộn ngang từ cùng `seriesListProvider(null)`; thẻ dùng `SeriesCard` (đổi sang nhận `SeriesSummary`). Chạm → chi tiết.
  3. **"Tập mới phát hành"**: `latestEpisodesProvider`, tile `LatestEpisodeTile` (tiêu đề, tên series, thời lượng `mm:ss` từ narration phát được, poster/ảnh dự phòng). Chạm → chi tiết series của tập đó (phát thật ở P4).
- Trạng thái từng khối (loading / lỗi / rỗng): widget chung `lib/shared/widgets/catalog_states.dart` (`CatalogLoading`, `CatalogError({error, onRetry})` phân biệt `NetworkException` và còn lại, `CatalogEmpty`); retry → `ref.invalidate(provider)`.
- Tách file < 250 dòng: `podcast_banner.dart`, `podcast_series_carousel.dart`, `latest_episode_tile.dart` (đặt ở `shared/widgets/` vì Home phase 5 dùng lại).
- Router: thêm `AppRoutes.podcast = '/podcast'`, mục `AppTab.podcast: GoRoute(...)` vào bản đồ tab của P2 (đúng thứ tự: sau Khám phá). Thanh tab tự có thêm mục.
- ARB vi+en: `podcastTitle`, `podcastFeatured`, `podcastSeriesHeading`, `podcastLatestHeading`, `podcastEmptyTitle`, `podcastEmptyMessage`, `catalogErrorNetwork`, `catalogErrorGeneric`, `catalogRetry`, `episodeMinutes` (ICU placeholder, không nối chuỗi).
- Cập nhật `SeriesCard`: nhận `SeriesSummary` (title, số tập qua ICU plural, cover/fallback). Gỡ props `secondary/large` nếu không còn dùng.

## Related files
Tạo: `features/podcast/ui/*.dart`, `shared/widgets/{latest_episode_tile,catalog_states}.dart`. Sửa: `series_card.dart`, `app_router.dart`, `app_routes.dart`, ARB.

## Todo
- [ ] `catalog_states.dart`
- [ ] `SeriesCard` nhận `SeriesSummary`
- [ ] `LatestEpisodeTile`
- [ ] `PodcastScreen` + tách file
- [ ] Route `/podcast` + mục `AppTab.podcast`
- [ ] ARB + `flutter gen-l10n`

## Success criteria
`flutter gen-l10n`, `dart format lib`, `flutter analyze` sạch; 3 lệnh grep/find "Verify" rỗng; mọi chuỗi từ ARB.

## Risks
- `SeriesCard` đang dùng ở Home/Search: sửa chữ ký làm vỡ chúng ngay → cập nhật tạm các chỗ gọi (phase 5-6 viết lại hẳn) hoặc để phase này thêm constructor mới và phase 5-6 xoá constructor cũ; chọn cách sau cùng cây vẫn build.
- Banner mặc định `viet-nam-thoi-phong-kien` có thể không tồn tại ở môi trường khác: đã có dự phòng series đầu.
