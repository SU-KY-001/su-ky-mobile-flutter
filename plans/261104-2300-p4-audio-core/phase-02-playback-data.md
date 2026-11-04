# Phase 2 - Episode detail + Playback: domain, data, providers (task 4.2)

Context: [plan.md](./plan.md). Cần phase 1 xong (hằng trong `audio_defaults.dart`). Mẫu cần theo: `lib/shared/catalog/data/catalog_parser.dart` (parse từng trường, `FormatException` nêu tên trường), `catalog_repository.dart` (`_guard`, `Result`), `catalog_providers.dart` (`cacheFor`). Đọc `lib/core/error/app_exception.dart` để biết `ApiException.errorCode`.

## Requirements
**Domain** (Dart thuần, bất biến)
- `lib/shared/catalog/domain/episode_detail.dart`: `EpisodeDetail{id, slug, title, description?, seriesSlug, seriesTitle, seriesCoverUrl?, narrations (List<Narration> đã có), previous?, next?, hasQuiz}` + `EpisodeLink{id, slug, title}`. Getter `Narration? playableFor(String? preferredId)`: narration `available` có id khớp, nếu không thì `available` đầu tiên (đã có `EpisodeSummary.playable`, tái dùng logic để không lặp). `Narration` cần thêm `narratorName?` nếu API có tên nhân vật (kiểm field `narrator` trước khi thêm; nếu rỗng ở dữ liệu thật thì không thêm).
- `lib/shared/audio/domain/playback_info.dart`: `PlaybackInfo{narrationId, episodeId, assetId, url (Uri https), mimeType, durationMs}`. Không có `progress`/`sync` (P5 thêm khi có consumer).

**Data**
- `catalog_parser.dart`: thêm `parseEpisodeDetail`; bỏ qua `entities/publicationInfo/viewer/series.sources`. `series.cover` `null` → `seriesCoverUrl = null`.
- `CatalogRepository.episodeDetail(String slug)` → `Result<EpisodeDetail>`, kiểm `isValidSlug` như `seriesDetail` (sai → `Err(ApiException 404 NOT_FOUND)` cục bộ).
- `lib/shared/audio/data/playback_repository.dart`: `abstract class PlaybackRepository { Future<Result<PlaybackInfo>> playback(String narrationId); }` + impl dùng `dioProvider`, `_guard` cùng kiểu catalog. `narrationId` kiểm UUID bằng hằng regex trước khi gọi. Parser: `audio.url` bắt buộc `https`; `durationMs` int > 0; id trong response phải khớp id đã yêu cầu, nếu không `FormatException`. Lỗi 404 `CONTENT_UNAVAILABLE` giữ nguyên `ApiException` (UI map). Không log body hay URL (URL là chữ ký truy cập).
- `playbackRepositoryProvider`; `episodeDetailProvider = FutureProvider.autoDispose.family<EpisodeDetail, String>` với `cacheFor(catalogStaleTime)` (đặt trong `catalog_providers.dart`). `playback` **không** cache (`no-store`), gọi trực tiếp từ controller.

## Risks
- Chưa có DTO thứ hai cho `narrator`: xem mục Domain. Kiểm bằng `curl` một episode có `FIRST_PERSON` nếu tồn tại; nếu không có, ghi "chưa kiểm" vào ADR.
- `durationMs` của narration (episode detail) và của `audio` (playback) có thể lệch; dùng giá trị của `playback` làm nguồn cho Player.

## Todo
- [x] `EpisodeDetail`, `EpisodeLink`, `playableFor`
- [x] Parser + `CatalogRepository.episodeDetail` + `episodeDetailProvider`
- [x] `PlaybackInfo` + `PlaybackRepository` + provider
- [x] `flutter analyze` sạch; không `Map<String, dynamic>` ra khỏi file parser
