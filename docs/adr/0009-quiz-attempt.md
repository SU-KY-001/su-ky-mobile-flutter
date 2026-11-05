# 0009 — Quiz attempts

The quiz screens now use the real API: `GET /api/quizzes` (public catalog),
`GET /api/episodes/{slug}/quiz` (signed in) and
`POST /api/quizzes/{quizId}/attempts` (signed in). The old client-side quiz
(one hardcoded quiz, answers checked locally, result kept in
SharedPreferences) is gone.

- **No per-question checking.** `GET /api/episodes/{slug}/quiz` returns
  questions and options but not the correct option or explanations. A
  "check answer" step cannot be honest without a submit, so the flow is
  select an option, advance, and submit on the last question. The server
  response is the only source of correctness, score and explanations. This
  matches RN; the earlier local checker and its feedback card were deleted.
- **Passing comes from the server.** The result carries `scorePercent`,
  `isPassed` and per-question verdicts. The UI shows `isPassed` and never
  compares `scorePercent` with a client constant (the old hardcoded 80%
  threshold is gone). `passScorePercent` is displayed on the intro screen only
  as information from the quiz payload.
- **`Idempotency-Key` is generated locally.** The API requires a UUID v4 per
  attempt and rejects a missing or malformed header. `newIdempotencyKey()`
  builds one with `Random.secure()` and the RFC 4122 version/variant bits; a
  new package for eight lines would not pay for itself. One key is generated
  when the attempt starts and is kept when submission fails, so a retry after
  a timeout/5xx/409 replays the server's verdict instead of creating a second
  attempt. Only "Try again" (`retake`) generates a new key.
- **Every question exactly once, in `sortOrder`.** The parser sorts
  `questions` by `sortOrder`; the view model refuses to submit unless the
  answer map covers every question, then builds `answers[]` by walking that
  sorted list. This satisfies the API's "all questions, no duplicates" rule.
- **`timeLimit` is ignored.** The API exposes an optional per-question
  `timeLimit`, but RN does not show a timer and the app has no timer UI. The
  field is not part of the domain model, matching RN; this is a known
  difference from the web client.
- **Topics come from the catalog, not `/api/topics`.** The filter chips are
  derived from the unfiltered `GET /api/quizzes?limit=50` response
  (`topicId`/`topicName`, first-seen order). RN does the same, so the planned
  `/api/topics` endpoint was dropped.
- **No pagination.** `limit=50` returns all nine seeded quizzes. If the
  catalog grows past 50 entries some quizzes will not be listed; adding a
  "load more" control was deferred until the API/UX needs it.
- **Guests use the route guard.** The list tab is public (it renders
  `hasCompleted: null` as "no badge"). Opening a quiz from the catalog, Player
  or Series hits `/episodes/:slug/quiz`, whose `authGuard` redirects to login
  with `returnTo`, then returns to the quiz. RN shows an in-screen lock
  instead; the guard produces the same result with no extra screen.
- **Refresh contract with P7.** After a successful submit the catalog is
  always invalidated (`hasCompleted`/`plays` change). Only when
  `result.isPassed` is `learningActivityProvider.bump()` called, which
  reloads weekly missions and XP. `xpAwarded` can be 0 on a later pass
  because quiz XP is granted once per quiz; the UI treats that as normal.
- **Location.** Domain, parser, repository and providers live in
  `lib/features/quiz/{domain,data}`, because only the quiz feature consumes
  them. `learningActivityProvider` stays in `core` so this feature does not
  import another feature.
- **Boundary validation.** The catalog card, quiz and result are decoded
  field by field in `quiz_parser.dart`; anything missing or malformed throws
  `FormatException`, which the repository logs (cause + stack) and returns as
  `UnknownException`. Answers and tokens are never logged. Unknown
  `category`-like values are not needed: only the fields present in the
  verified contract are read.

Not verified yet: a real signed-in list/detail request, a real `POST` with
the `user` account, the replay path (same key, `Idempotent-Replayed`),
`IDEMPOTENCY_KEY_REUSED`/`IN_PROGRESS`, `xpAwarded == 0` on a second pass,
and 404 for an episode without a quiz. Deferred to P11 with the rest of the
runtime checks.
