# 0008 — Weekly missions and XP

Signed-in clients read `GET /api/me/weekly-missions` without a
`weekStartDate`: the server anchors the week (Monday 00:00
Asia/Ho_Chi_Minh) and returns `weekStartDate`, `weekEndDate`, `totalXp`
and `items[]`. The response is the only source of XP for the UI.

- **Location.** Domain and repository live in `lib/shared/missions/`
  (`domain/weekly_missions.dart`, `data/weekly_missions_repository.dart`,
  `missions_providers.dart`). The missions screen and P8's profile both
  need the same data, and a feature must not import another feature's
  internals.
- **Boundary validation.** `totalXp`, `weekEndDate` and `items` are
  required; a missing or malformed one fails the whole request with an
  `AppException`. An unknown `activityType` or `status` drops only that
  item and logs the value, so a new server-side mission kind does not
  break the screen.
- **Refresh without polling.** `weeklyMissionsProvider` watches
  `learningActivityProvider` (`lib/core/activity/learning_activity.dart`).
  P5's `ProgressSync` bumps it when an episode completes; P6 must bump it
  after a passed quiz. Each bump reloads missions and XP. There is no
  timer and no polling. The provider is `autoDispose`, so XP earned on
  another client appears when the screen is opened again.
- **One screen, no honour board or mission detail.** The RN app shows
  missions only as a profile section; the API has no honour board and no
  per-mission detail content. Keeping those screens meant inventing copy
  and streaks, so they were deleted together with their routes, mock data
  and l10n keys. The list screen shows `totalXp`, `completedCount`, the
  week end and each mission's title, progress bar, `progressCount/targetCount`,
  `xpReward` and status.
- **Title ownership.** `title` is server-authored content and is rendered
  as-is. UI labels, status chips and the week-end date stay in ARB.

Not verified yet: a real request with a signed-in account, a week rollover,
and the refresh after episode completion. Deferred to P11 with the rest of
the runtime checks.
