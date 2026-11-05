# Sử Ký (su_ky_mobile)

Flutter mobile app. Architecture: feature-first MVVM — see
[docs/adr/0001-architecture.md](docs/adr/0001-architecture.md) and
[AGENTS.md](AGENTS.md).

## Screens

Tabs (ADR 0004): Discover (`/`), History (`/history`), Podcast (`/podcast`),
Quiz (`/quizzes`) and Profile (`/profile`). Root routes opened over the tab
shell: Search (`/search`), Login (`/login`), Series (`/series/:slug`), Player
(`/player`), episode quiz (`/episodes/:slug/quiz`, signed in), event detail
(`/events/:slug`), weekly missions (`/weekly-missions`) and release schedule
(`/schedule`).

Series, episodes, historical periods, search, quizzes, weekly missions,
listening history, the timeline and the release schedule come from the real
API configured with `API_BASE_URL` (ADR 0005). The History tab lists events
filtered by period; an event shows its citations and related series (ADR 0011).

The Player streams real audio (ADR 0006): signed-in users only, background
playback with a notification, speed, sleep timer and narration switch. Guests
are asked to sign in and the episode starts after login. On Android 13+ the app
asks once for the notification permission; playback works without it.
Vietnamese is the initial locale; all copy also has English translations.

## Episode quiz

Quiz screens use the real API (ADR 0009): `GET /api/quizzes`,
`GET /api/episodes/:slug/quiz` and `POST /api/quizzes/:quizId/attempts` with a
locally generated `Idempotency-Key`. Open a quiz from the Quiz tab, a Series
entry or the Player. The flow is an introduction, one answer per question,
submit on the last question, then results with score and per-question review.

Pass/fail and XP come from the server response; the UI never compares the
score with a client threshold. A passed attempt refreshes weekly missions.
Guests opening an episode quiz are redirected to login with `returnTo`, then
returned to the quiz.

## Listening progress and missions

Progress syncs per narration and resume prefers the local position, then server
progress, then zero (ADR 0007). Weekly missions and XP use
`GET /api/me/weekly-missions` (ADR 0008) and reload when learning activity
changes; there is no polling. The Profile tab shows the XP card and recent
listening history; its notification button opens the release schedule, which is
public and loaded per month (ADR 0010).

VS Code: select an Android emulator/device, choose `Su Ky - Android` and press F5.
The configuration loads the local `env/dev.json` copied from the example.

Sign-in, sign-up and sign-out use the real API (ADR 0003); the session token is
kept in secure storage. Test credentials go in the git-ignored
`env/accounts.local.json` (see `env/accounts.example.json`), never in
`env/dev.json`: `--dart-define-from-file` embeds its values in the APK. Inter is
bundled locally from the supplied Google Fonts archive, including weights
400–800 and italic. The SIL OFL license is included. See ADR 0002.

## Requirements
Flutter 3.47+ / Dart 3.13+.

## Weekly missions layout
Weekly missions uses the shared `AppPage` layout: centered content up to 520
logical pixels and 24-pixel page padding. It is a root route opened over the tab
shell (no tab bar), see ADR 0004. The header scrolls with the content; calendar
and mission section headings wrap on narrow phones.

## Run
```sh
flutter pub get
cp env/dev.example.json env/dev.json      # set API_BASE_URL
flutter gen-l10n
flutter run --dart-define-from-file=env/dev.json
```
Android only. Generated l10n (`lib/l10n/gen/`) is git-ignored; run
`flutter gen-l10n` after clone or after editing `lib/l10n/*.arb`.

On Windows PowerShell, create the local config with
`Copy-Item env/dev.example.json env/dev.json`. The example API URL is a placeholder;
replace it with the backend URL before using API-backed functionality.
Run `flutter devices`, then select an Android device explicitly:
`flutter run -d <android-device-id> --dart-define-from-file=env/dev.json`.
If no Android device is listed, start an Android emulator or connect a phone
with USB debugging enabled.

If startup shows a blank screen, check that the run command includes the config
file. A missing or invalid `API_BASE_URL` throws before `runApp`, so a connected
debug service alone does not mean the UI started. After changing build-time
configuration, stop the current run with `q` and launch again. Chrome is not a
supported target for this Android app.

## Configuration (build-time, `--dart-define`)
| Key | Values | Default | Purpose |
|-----|--------|---------|---------|
| `ENV` | `dev` `staging` `prod` | `dev` | Logging verbosity, debug banner. Invalid value aborts startup. |
| `API_BASE_URL` | absolute http(s) URL | none (required) | REST backend root. Missing/invalid aborts startup. |

Files `env/*.json` are git-ignored; commit only `env/*.example.json`.

Secrets MUST NOT go in `--dart-define` (extractable from the binary).

## Stack
Riverpod (state/DI), go_router, dio (REST), shared_preferences (prefs),
flutter_secure_storage (tokens), connectivity_plus, intl + ARB (vi default, en).
No local database or codegen packages: there is no offline cache, and data
models are hand-written parsers (ADR 0012).

## Quality gates
```sh
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Build (Android, distributed outside stores)
```sh
flutter build apk --release --dart-define-from-file=env/prod.json
```
Rollback: redistribute the previous APK; config is build-time only.
