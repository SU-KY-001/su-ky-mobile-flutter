# Sử Ký (su_ky_mobile)

Flutter mobile app. Architecture: feature-first MVVM — see
[docs/adr/0001-architecture.md](docs/adr/0001-architecture.md) and
[AGENTS.md](AGENTS.md).

## Sử Kế reference UI

Five implemented screens: Discover (`/`), Search (`/search`), Login (`/login`),
Series (`/series/bach-dang-938`) and Player (`/player`). Vietnamese is the initial
locale; all copy also has English translations. Profile opens the login form.

## Episode quiz

Episode 2 of Bach Dang 938 includes a six-question local sample quiz. Open
`Ôn tập với Quiz` from its Series entry or Player. The route is
`/episodes/1/quiz` (episode indices follow the existing zero-based player).
Other episode IDs display an unavailable state rather than another episode's quiz.

The quiz includes an introduction, answer selection and feedback, results,
and expandable answer review with correct/incorrect filters. Answers lock after
checking; completion calculates accuracy and elapsed time. Starting a quiz pauses
the simulated player. Leaving an unfinished attempt requires confirmation.

The last completed result is stored locally in SharedPreferences under a versioned
quiz key, including answers, completion time and duration. It survives app restarts;
unfinished attempts do not. Results are device-local, not linked to the mock login.
Read/write failures are visible and a failed result write can be retried.
`QuizRepository` can be replaced when a quiz API and real authentication exist.
No audio clip playback or points/badge economy is simulated by the quiz.

Quiz screens use the bundled Inter family, white backgrounds and existing red
accents. Sample question copy and explanations live in the Vietnamese/English ARB
files; the ordered question IDs and correct options live in `QuizDefinition`.
Changing the question/answer schema requires a new quiz ID to isolate old results.

To capture UI test previews: `flutter test --dart-define=CAPTURE_UI=true`.
Images are written to `build/ui_previews/`. Quiz coverage includes scoring,
answer locking, restarting, local persistence, storage errors, exit confirmation,
review filtering and navigation at 320/390 logical pixels.

VS Code: select an Android emulator/device, choose `Su Ke - Android` and press F5.
The configuration loads the local `env/dev.json` copied from the example.

This implementation uses local artwork cropped from the supplied reference and
an in-memory playback simulation. Play/pause, seeking, episode selection,
favorites, bookmarks, playback speed and sleep timer share state across routes.
Audio streaming, account authentication, OAuth, downloads and sharing need real
services; their placeholder actions display a demo notice. No new packages were
added. Inter is bundled locally from the supplied Google Fonts archive, including
weights 400–800 and italic. The SIL OFL license is included. See ADR 0002.

## Requirements
Flutter 3.47+ / Dart 3.13+.

## Weekly missions layout
Weekly missions uses the shared `AppPage` layout: centered content up to 520
logical pixels, 24-pixel page padding, and the same three navigation destinations
as Discover. The header scrolls with the content; calendar and mission section
headings wrap on narrow phones. Layout tests cover 320, 390 and 1440-pixel widths,
scrolling to the final card and navigation callbacks.

The listening challenge “Hành trình chưa dừng lại” opens
`/weekly-missions/listening`, with completion requirements, sample progress,
and a recommended episode. “Nghe ngay” and “Tiếp tục nhiệm vụ” open episode 3
in the existing simulated player. The medal button opens
`/weekly-missions/honours`, a sample completion summary for week 42 of 2024,
with a badge collection preview. Back, profile and Discover actions use the
existing navigation. Share displays the sample-data notice; no external sharing
service is connected. Points, badges and listening requirements are illustrative
and are not awarded, persisted or synced to an account. Both screens include
Vietnamese/English copy and layout tests at 320, 390 and 1440 logical pixels.
`flutter test --dart-define=CAPTURE_UI=true` also writes previews of both screens
to `build/ui_previews/`.

## Run
```sh
flutter pub get
cp env/dev.example.json env/dev.json      # set API_BASE_URL
dart run build_runner build --delete-conflicting-outputs   # drift/freezed/json
flutter gen-l10n
flutter run --dart-define-from-file=env/dev.json
```
Android only. Generated files (`*.g.dart`, `*.freezed.dart`, `lib/l10n/gen/`) are git-ignored; regenerate after clone.

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
Riverpod (state/DI), go_router, dio (REST), drift (offline DB),
shared_preferences (prefs), flutter_secure_storage (tokens), connectivity_plus,
freezed/json_serializable (models), intl + ARB (vi default, en).

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
