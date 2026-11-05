# Phase 1 - Catalog domain + data + providers (task 3.1)

Context: [plan.md](./plan.md). Đọc `AGENTS.md` (root), `lib/core/AGENTS.md`, `lib/features/AGENTS.md`. Mẫu cần theo: `lib/features/auth/data/auth_repository.dart` (interface + `_guard` + provider), `lib/features/quiz/data/quiz_attempt_codec.dart` (parse từng trường, ném `FormatException`).

## Requirements
**Domain** (`lib/shared/catalog/domain/`, Dart thuần, bất biến, không import Flutter)
- `Paged<T>{items,page,limit,total}` + `hasMore => page * limit < total`.
- `SeriesSummary{id,slug,title,description?,startYear?,endYear?,coverUrl?,landscapeUrl?,episodeCount,publishedAt?}`.
- `SeriesDetail{id,slug,title,description?,creatorName?,startYear?,endYear?,coverUrl?,landscapeUrl?,episodes}`; `EpisodeSummary{id,slug,title,description?,publishedAt?,posterUrl?,sortOrder,narrations}`; `Narration{id,type,durationMs?,available}`, `enum NarrationType{firstPerson,thirdPerson}`.
- Getter: `EpisodeSummary.playable` (narration `available` đầu tiên hoặc `null`); `SeriesDetail.firstPlayableEpisode`; tổng thời lượng phút từ `durationMs` của narration phát được.
- `HistoricalPeriod{id,slug,name,startYear?,endYear?}`; `LatestEpisode{seriesSlug,seriesTitle,episode}`.

**Data** (`lib/shared/catalog/data/`)
- `catalog_parser.dart`: hàm parse từng loại, kiểm kiểu và rỗng từng trường (URL lấy từ `cover.url`; `null` khi `cover` là `null`); enum lạ ném `FormatException`. Không `Map<String, dynamic>` đi ra ngoài file.
- `catalog_repository.dart`: `abstract class CatalogRepository { listSeries({page, limit, query, periodId}); seriesDetail(String slug); periods(); latestEpisodes(); }` đều `Future<Result<...>>`. Impl dùng `dioProvider`, `_guard` như `ApiAuthRepository`: `DioException` → `mapDioException`, `FormatException` → `UnknownException` + `AppLogger.error` kèm cause/stack, không log body.
- `latestEpisodes()`: gọi `listSeries(limit: latestSeriesScanCount)`, rồi `seriesDetail` song song (`Future.wait`), lỗi từng series → log + bỏ qua, tất cả lỗi → `Err` của lỗi đầu; gộp tập có `playable`, sắp `publishedAt` giảm (null cuối), cắt `latestEpisodesCount`.
- Slug kiểm bằng `isValidSlug` (`[a-z0-9-]+`) trước khi gọi; sai → `Err(ApiException(..., statusCode: 404, errorCode: 'NOT_FOUND'))` cục bộ.
- `catalog_providers.dart`: `catalogRepositoryProvider`; `FutureProvider.autoDispose` cho `seriesListProvider.family(String? periodId)` (trang 1, `seriesPageSize`), `seriesDetailProvider.family(slug)`, `periodsProvider`, `latestEpisodesProvider`. Mỗi provider mở `Result` (`Ok` trả giá trị, `Err` ném `error`) và gọi `ref.cacheFor(catalogStaleTime)`.

**Core** (hạ tầng, không import feature)
- `lib/core/di/cache_for.dart`: `extension RefCacheFor on Ref { void cacheFor(Duration d) }` = `keepAlive` + `Timer` đóng link, huỷ khi dispose.
- `lib/core/di/app_retry.dart`: `Duration? appRetry(int count, Object error)`: `null` nếu `count >= retryMaxAttempts` (=2) hoặc lỗi là `AppException` không `isRetryable`; ngược lại backoff `retryBaseDelay * 2^count`. Hằng đặt tên, không số trần.
- `lib/main.dart`: `ProviderScope(retry: appRetry, ...)`. Trước khi viết, kiểm chữ ký thật trong Riverpod 3.4 (đọc source trong pub cache); nếu `retry` khác tên/kiểu thì theo source, không đoán.
- `lib/shared/catalog/catalog_constants.dart`: `seriesPageSize=20`, `latestSeriesScanCount=6`, `latestEpisodesCount=6`, `catalogStaleTime=60s`, `featuredSeriesSlug='viet-nam-thoi-phong-kien'` (RN `PodcastScreens.tsx`, ghi rõ nguồn trong comment), tên query param, `slugPattern`.

## Related files
Tạo: toàn bộ file kể trên. Sửa: `lib/main.dart`, `lib/shared/mock/mock_catalog.dart` (thêm `featuredSeriesSlug` cho Player tạm, nếu chưa có).

## Todo
- [ ] Domain bất biến
- [ ] Parser + repository + `latestEpisodes`
- [ ] Providers + `cacheFor`
- [ ] `appRetry` + `ProviderScope(retry:)`
- [ ] Hằng số

## Success criteria
`flutter analyze` sạch; mọi file < 250 dòng; không `Map<String, dynamic>` công khai; không thư mục rỗng; mọi provider có consumer ở phase 3–6 (`episodeDetail`/`topics` **không** có ở đây).

## Risks
- `cover.url` có thể là chuỗi rỗng: coi là `null`.
- Không log token/body. Số lần gọi `latestEpisodes` bị chặn bởi hằng số.
