# 0010 — Profile, listening history and release schedule

Profile now shows the signed-in user's XP and recent listening, and the bell
opens a public month-by-month release schedule. Data comes from the real API:
`GET /api/me/listening-history` and `GET /api/showcase/releases`.

- **History lives in the Profile, not a tab.** RN shows "Đã nghe gần đây" in
  its account screen and has no history tab. `AppTab.history` stays untouched;
  the History tab belongs to P9 (timeline and events). This also avoids two
  screens competing for the same `listening-history` data.
- **No status filter and no pagination.** RN sends one first page with
  `status=all` and renders it as-is. The app fixes `page=1`, `limit=10` and
  `status=all` as named constants; the earlier report line asking for
  filtering and paging was above parity and was corrected.
- **History is in `lib/shared/history/`.** The Profile consumes it, and it
  must refresh after an episode or a passed quiz. `listeningHistoryProvider`
  watches `learningActivityProvider` (P5) and `signedInProvider`: guests get
  `null` without a request. Placing it in a feature would force a
  cross-feature import, which `AGENTS.md` forbids.
- **`percent` is a decimal percentage.** The API can send `7.142857…`; the
  parser clamps it to `[0, 100]` and rounds it once, so every widget shows the
  same integer. The API's `isCompleted`, `lastListenedAt` and `total` are not
  parsed: nothing reads them, and a bad value would drop a good row.
- **Known limit: stale after a partial listen.** The history refreshes only
  when `learningActivityProvider` bumps (episode finished, quiz passed). A
  partly listened episode shows its old percent until Retry or app restart.
  RN behaves the same way.
- **No text label on the row.** The whole row plays; a play icon marks it. A
  finished episode restarts from 0, so a "continue" label would be wrong.
- **Continue listening uses the playback endpoint's position.** The tile
  calls `playFromUi(..., narrationId: lastNarrationId)`; P5's resume logic
  reads `progress.positionMs` from `/narrations/{id}/playback`. The
  `lastPositionMs` field of history is not used to seek.
- **Unavailable episodes have no Play button.** The API flags an episode or
  series that is no longer published with `available: false`; playing it
  would fail. The row is still shown (dimmed) so the user recognises it.
- **The XP card links out instead of duplicating missions.** The Profile shows
  `totalXp` and `completedCount` only; tapping opens `/weekly-missions`, which
  already owns the mission list (P7). This differs from RN, which lists
  missions inside the account screen, but keeps one owner for mission UI and
  avoids importing `features/weekly_missions` from `features/profile`.
  A zero-XP, zero-mission week still renders the card (`0 XP`, no missions
  done); that is a valid response, not an error.
- **The schedule month is a local calendar month.** `from` is the first day
  of the shown month at local midnight converted to UTC, `to` is the first day
  of the next month (exclusive). That is always 28–31 days, below the API's
  62-day limit, and crossing December resolves the next year. The shown month
  is `ScheduleViewModel` state (immutable `DateTime`), not `setState`.
- **The schedule is public.** No auth guard is added; guests can browse it.
  Play still goes through `playFromUi`, so a guest is asked to sign in exactly
  as everywhere else. The Play button appears only for `released: true`.
- **Release rows are sorted client-side.** The API does not guarantee order,
  so the repository sorts by `scheduledAt` ascending.
- **Boundary validation.** Both parsers decode field by field. A malformed
  history entry or release is skipped and logged (cause + stack) so one bad
  row cannot empty the screen; a missing top-level `items` fails the request
  with `UnknownException`. Errors map to `AppException` via `mapDioException`
  and surface as `AsyncError`, never swallowed.

Not verified yet: a signed-in `listening-history` request from the app, the
refresh after a completed episode, and any release row rendered against real
data. The live API returned empty release lists for every month checked
(2026-01 … 2027-01), so the empty state is the current real path. Deferred to
P11 with the rest of the runtime checks.
