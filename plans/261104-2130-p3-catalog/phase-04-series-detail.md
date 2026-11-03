# Phase 4 - Chi tiết Series (task 3.4)

Context: [plan.md](./plan.md). Cần phase 1-3. Hiện `series_screen.dart` (127 dòng) không có view model, lặp 6 tập cứng theo `MockCatalog.episodeSeconds`; route `AppRoutes.series = '/series/bach-dang-938'`.

## Requirements
Nguồn UX: RN `PodcastScreens.tsx:161-270`.
- Route `AppRoutes.series = '/series/:slug'` + `seriesFor(String slug)`; router đọc `state.pathParameters['slug']`, truyền `SeriesScreen(slug: ...)`. Sửa mọi chỗ gọi `AppRoutes.series` cũ (Home, Search, Player, `RelatedEpisodeTile`): dùng `seriesFor(...)`; Player tạm dùng `MockCatalog.featuredSeriesSlug`.
- `SeriesScreen` (`ConsumerWidget`) `ref.watch(seriesDetailProvider(slug))`:
  - loading/lỗi/rỗng qua `catalog_states.dart`; `NOT_FOUND` (kể cả slug sai mẫu) → màn "không tìm thấy" kèm nút về Podcast.
  - Hero: ảnh `landscapeUrl ?? coverUrl` hoặc dự phòng, tiêu đề, tên người tạo, số tập + tổng phút (ICU), mô tả.
  - Nút chính "Phát tập có audio": tập `firstPlayableEpisode` → `context.push(AppRoutes.player)` (audio mock tới P4); không có tập nào phát được thì nút bị vô hiệu + thông báo `seriesNoAudio`.
  - Danh sách tập (`EpisodeListTile`): số thứ tự, tiêu đề, thời lượng `mm:ss`; có audio → icon play, chạm → player (tạm); không audio → mờ (opacity theo token, RN 0.72), nhãn `episodeNoAudio`, chạm → `SnackBar` `episodeNoAudioNotice`.
- **Gỡ** nút quiz theo tập khỏi `episode_list_tile.dart` (P6.4 thêm lại với slug).
- Hằng `unavailableOpacity` đặt tên. Không số trần.
- Tách `series_hero.dart`, `episode_list_tile.dart` (viết lại) để mọi file < 250 dòng.
- ARB: `seriesNotFound`, `seriesNoAudio`, `seriesPlayFirst`, `episodeNoAudio`, `episodeNoAudioNotice`, `seriesEpisodeCount` (plural); xoá key mock không còn dùng (`episode1..6`, `sixTracks`, `listened`, `remaining`... chỉ khi `grep` xác nhận không còn ở đâu).

## Related files
Sửa: `app_routes.dart`, `app_router.dart`, `features/series/ui/series_screen.dart`, `episode_list_tile.dart`; tạo `series_hero.dart`. Gọi tới: Home, Search, `player_screen.dart`, `related_episode_tile.dart`.

## Todo
- [ ] Route `:slug` + `seriesFor` + cập nhật mọi chỗ gọi
- [ ] `SeriesScreen` nối `seriesDetailProvider`
- [ ] `EpisodeListTile` badge audio, gỡ nút quiz
- [ ] ARB + dọn key mock

## Success criteria
`flutter gen-l10n`, `dart format lib`, `flutter analyze` sạch; `grep -rn "bach-dang-938" lib` rỗng; `grep -rn "episodeSeconds" lib/features/series` rỗng; 3 lệnh "Verify" rỗng.

## Risks
- Player vẫn mock nên bấm Phát sẽ mở Player mock; tạm thời, P4 xoá. Ghi rõ trong ADR phase 7.
- Slug từ deep link: kiểm `isValidSlug` trước khi gọi.
