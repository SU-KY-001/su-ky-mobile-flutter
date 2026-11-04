# 0005 — Catalog layer

The catalog (series, episodes, historical periods) is used by Home, Podcast,
Series detail and Search, so it lives in `lib/shared/catalog/` (`domain/`,
`data/`), not in one feature.

- `CatalogParser` validates server JSON field by field and throws
  `FormatException`; the repository maps it to `UnknownException`. Raw maps never
  leave `data/`. An empty image URL counts as no image.
- `CatalogRepository` returns `Result`. Providers unwrap it and throw the typed
  `AppException`, so `AsyncValue` errors keep their type and `appRetry` can tell
  retryable from non-retryable failures.
- `ProviderScope(retry: appRetry)`: Riverpod 3 retries every failing provider up
  to 10 times by default. We retry only retryable `AppException`s, at most twice.
- `ref.cacheFor(60s)` keeps `autoDispose` catalog providers alive for 60 seconds,
  the RN query client `staleTime`.
- The API has no episode list endpoint. "Latest episodes" scans the first 6
  series (`GET /api/series/{slug}` in parallel), keeps episodes with playable
  audio, sorts by `publishedAt` and takes 6, exactly like RN `latestEpisodes`.
  One failing series is logged and skipped; only when all fail is it an error.
  We chose this over adding `GET /api/episodes` to the API.
- An episode is playable when one of its narrations has `available == true`
  (server rule). Episodes without audio stay listed but dimmed.
- Images: `CoverArt` loads `https` URLs and falls back to bundled artwork chosen
  deterministically from the slug. Every real series has `cover: null` today, so
  no image-cache package was added.
- Search calls `GET /api/series?q=` after a 400 ms debounce, with at least 2
  characters. Each keystroke disposes the previous run, so stale responses are
  dropped. The server matches `title` only.

Consequences: tapping Play or an episode still opens the mock Player until the
audio engine lands (P4). Tests written against the old mock catalog are rewritten
in P11.
