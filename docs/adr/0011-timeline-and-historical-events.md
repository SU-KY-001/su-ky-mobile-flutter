# 0011 — History timeline and historical events

The History tab lists historical events from `GET /api/historical-events` and
opens a detail page with cited sources and related series. The live API holds 9
events across 5 periods; every request below is public (no sign-in).

- **Events live in `lib/shared/catalog/`.** Home, the History tab and the event
  detail page all consume catalog data, so the domain model, parser, repository
  methods and providers sit next to series and periods (ADR 0005), not inside
  `features/timeline`. The feature only owns its UI.
- **One model for list and detail.** Both endpoints return the same shape, so
  `HistoricalEvent` is parsed once and used by the timeline row and the detail
  page. `EventCitation` keeps only `locator`, `excerpt`, `source.title` and
  `source.author`; `reviewedAt`, `time`, phases of periods and the other source
  fields are not read.
- **The server's `timeLabel` is used verbatim.** It already formats BCE years,
  ranges and approximations ("Khoảng 500 TCN – Khoảng 111 TCN"). Parsing `time`
  would duplicate that logic and risk sign/precision mistakes. The timeline
  axis drops the "Khoảng " prefix the way RN does; the detail page shows the
  full label.
- **No pagination.** `GET /api/historical-events` is called with `page=1` and
  `limit=CatalogDefaults.eventsLimit` (50, the server maximum). The public
  history is far smaller. Known limit: if the server ever holds more than 50
  events, rows after the 50th are not shown; adding paging means changing this
  decision.
- **List rows are resilient, detail is strict.** One malformed event row is
  skipped and logged (cause + stack) so a single bad record cannot empty the
  timeline; the response still fails when `items` is missing. The detail
  endpoint has no redundant rows, so any invalid field fails that request and
  surfaces as `CatalogError` with Retry.
- **`PeriodPills` is shared.** The widget moved from `features/home/ui` to
  `shared/widgets` and now takes `selected` and `onSelect`. Home and History
  each own a separate `Notifier<String?>` selection, so switching periods in
  one tab does not change the other. Home keeps its `HomeViewModel`.
- **Related series use the real link.** `GET /api/series?eventId={id}` returns
  the series whose primary event this is. The section loads independently,
  shows nothing while loading, and hides entirely when the list is empty or
  fails (the error is logged). RN instead opens one hard-coded series slug; the
  live query avoids a stale constant and events without a series simply have
  no section.
- **No cover image.** The API sends no artwork for events. The list row and the
  detail header use `EventColorBlock` (theme colours) instead of RN's bundled
  per-slug fallback art.
- **The detail route is outside the shell.** `/events/:slug` is a top-level
  `GoRoute` like `/series/:slug`, so the tab bar is hidden. It is public; no
  auth guard is added. A bad slug is rejected by `isValidSlug` before any HTTP
  call and mapped to `404 NOT_FOUND`.
- **No mock phase.** Tasks 9.0a/9.0b (mock UI first) were dropped: the real API
  returns usable data now, so building mock screens would only add code to
  delete in the same plan.
- **The "Chính sử" fallback is gone.** RN renders "Chính sử" when a citation's
  `locator` is empty. The parser requires a non-empty `locator`, so that branch
  cannot occur; `eventSourceFallbackAuthor` covers a missing `source.author`
  instead.

Known limits / not verified: the app has not run on an emulator, so the layout
with many rows, scrolling and the real bundled art are untested. Only the
empty related-series case and one linked series were observed live. Runtime
checks are deferred to P11.
