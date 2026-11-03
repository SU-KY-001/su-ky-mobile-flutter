# Phase 4 - Player + MiniPlayer + điểm vào Phát; gỡ audio mock (tasks 4.0, 4.4, 4.5)

Context: [plan.md](./plan.md). Cần phase 3. Đọc `lib/features/AGENTS.md`, `lib/features/player/ui/player_screen.dart` (232 dòng, sắp vượt 250: tách widget), `lib/shared/widgets/mini_player.dart`, `lib/app/router/app_shell.dart`.

## Requirements
**Player** (`lib/features/player/ui/`, tách widget con, `player_screen.dart` ≤ 250 dòng)
- Đọc `playbackControllerProvider` và `playbackPositionProvider`; không còn `audioViewModelProvider`/`MockCatalog`.
- Hiển thị: tiêu đề tập, `series.title`, ảnh `CoverArt` (seed = slug series, tự dự phòng), thanh tua (`Slider` theo `durationMs`), thời gian đã nghe/còn lại bằng `audioTime` (chuyển hàm này sang `lib/shared/audio/audio_time.dart` vì `audio_view_model.dart` bị xoá; `latest_episode_tile.dart` đang import nó), nút tốc độ (`playbackSpeed`), -15 s, Phát/Tạm dừng, +15 s, hẹn giờ ngủ, "Nghe lại" (`restart`), nút xuống thu nhỏ (`context.popOrGo(AppRoutes.home)`), liên kết sang `AppRoutes.seriesFor(seriesSlug)` thay `MockCatalog.featuredSeriesSlug`.
- 4.0 chip ngôi kể: chỉ khi `episode.narrations.where(available).length > 1`; nhãn theo kiểu (`narrationFirstPerson`/`narrationThirdPerson`), chọn gọi `switchNarration`.
- Thẻ tập kế: chỉ khi `episode.next != null`, bấm gọi `playEpisode(next.slug)`; `previous` chưa có UI (RN không có; không thêm).
- Nút quiz ở Player **ẩn trong P4**: route quiz còn nhận chỉ số tập mock (`quizFor(int)`), không ánh xạ được sang tập thật. Quay lại ở P6 khi quiz theo slug (ghi vào ADR và report).
- Trạng thái: đang tải (`playerLoading`), lỗi theo `PlaybackError` có nút thử lại (`playerRetry` gọi lại `playEpisode(slug, narrationId)`), rỗng khi mở `/player` mà chưa có tập (`playerEmpty` + nút về Podcast).
- Bỏ nút yêu thích/lưu và mọi chuỗi mock (`bachDang`, `author`, `tideRising`, `nextEpisode`, `nextTitle`, `playingCollection`, `collectionTitle`…): sau khi sửa, `grep` từng key trong `lib/` (ngoài `l10n/gen`); key nào còn consumer (`bachDang` đang dùng ở Search/Quiz) thì giữ, key không còn consumer thì xoá khỏi cả hai ARB.

**Thông báo lỗi (ARB vi+en, theo RN)**: `playerUnavailable` "Tập này chưa có bản thu sẵn sàng.", `playerNetworkError` "Không thể tải âm thanh từ máy chủ.", `playerPlaybackError` "Không phát được âm thanh. Thử lại.", `playerLoading` "Đang tải…", `playerRetry`, `playerEmpty`, `narrationFirstPerson` "Lời kể nhân vật", `narrationThirdPerson` "Người dẫn chuyện", `narrationLabel` "Góc kể". Subtitle `Sử Ký · {series} · Tập {n}` bằng ICU placeholder (`playerSubtitle(series, number)`), số tập lấy từ thứ tự trong series nếu có, nếu không bỏ phần "Tập"; **chưa kiểm** có `sortOrder` trong `EpisodeDetail` (không có trong hợp đồng đã đọc), nếu không có thì chỉ hiện `Sử Ký · {series}`.

**MiniPlayer / shell**
- `mini_player.dart`: đọc controller; tiêu đề, phụ đề series, -15 s, Phát/Tạm dừng, vạch tiến độ từ `playbackPositionProvider`/`durationMs`; bấm mở `AppRoutes.player`.
- `app_shell.dart`: hiện MiniPlayer khi `state.episode != null` (thay cờ `loaded`).

**Điểm vào Phát** (phase này gọi thẳng `playbackControllerProvider.notifier.playEpisode(slug, narrationId)` rồi `context.push(AppRoutes.player)`; phase 5 thay bằng `playFromUi` có cổng khách và xử lý `PlayOutcome.needsLogin`, nên phase 4 chưa merge riêng)
- `features/series/ui/episode_list_tile.dart`: truyền `episode.slug` + narration phát được, rồi `context.push(AppRoutes.player)`.
- `series_screen.dart` (nút "Nghe từ đầu", hiện gọi `startOver()`): `series.firstPlayableEpisode`.
- `features/home/ui/continue_listening_card.dart`: dùng `lastListenProvider` + `episodeDetailProvider(slug)` (tiêu đề), hiện còn lại bao lâu; ẩn khi không có tập gần nhất.
- `features/weekly_missions/ui/mission_detail_screen.dart`: bỏ `playEpisode(recommendedEpisode)`, nút "Nghe tiếp" `context.go(AppRoutes.podcast)` (plan quyết định 9).
- `features/quiz/ui/quiz_view_model.dart`: gọi `playbackControllerProvider.notifier.pause()`.
- `shared/widgets/latest_episode_tile.dart`: chỉ đổi import `audioTime`.

**Xoá**: `lib/shared/audio/audio_view_model.dart`; `MockCatalog.episodeSeconds`, `initialPositionSeconds` (và `episodeTitle(l, index)` trong `su_ke_widgets.dart` nếu không còn consumer sau `grep`); `featuredSeriesSlug` trong `catalog_constants.dart` **chỉ nếu** Podcast banner không dùng (đang dùng, giữ).

## Risks
- `quiz_screen_test`, `quiz_view_model_test`, `mission_detail_screen_test`, `test/shared/audio/audio_view_model_test.dart` vỡ; sửa ở P11 (đã chấp nhận trong plan).
- Slider kéo gọi `seek` liên tục: dùng `onChangeEnd` để seek, `onChanged` chỉ cập nhật giá trị tạm trong `StatefulWidget` (state UI tạm thời, được phép).

## Todo
- [x] `audio_time.dart` + ARB key mới (vi+en), xoá key mồ côi
- [x] `player_screen.dart` + widget con, chip ngôi kể, thẻ tập kế, trạng thái tải/lỗi/rỗng
- [x] `mini_player.dart` + `app_shell.dart`
- [x] 5 điểm vào Phát (series tile, nút nghe từ đầu, Home, Missions, Quiz pause)
- [x] xoá `audio_view_model.dart` và mock audio; `grep` không còn tham chiếu
- [x] Verify: `gen-l10n`, `dart format lib`, `analyze` sạch, 3 lệnh grep/find rỗng
