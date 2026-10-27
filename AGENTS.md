# AGENTS.md — su_ky_mobile (root)

Flutter app, feature-first MVVM (Flutter official architecture). Read the
nearest nested `AGENTS.md` before editing a folder; it overrides this file.

## Commands
```sh
flutter pub get
cp env/dev.example.json env/dev.json
dart run build_runner build --delete-conflicting-outputs   # after changing drift/freezed/json
flutter gen-l10n                                            # after changing lib/l10n/*.arb
flutter run --dart-define-from-file=env/dev.json
dart format lib test
flutter analyze        # must be clean
flutter test           # must pass
```
Definition of done: format + analyze + test green, docs updated.

## Layout
```
lib/
  main.dart          bootstrap: error hooks, config, runApp
  app/               wiring: App widget, router, theme
  core/              cross-feature infra: config, di, error, logging, network, storage
  l10n/              ARB files (app_vi.arb template, app_en.arb); output in l10n/gen (ignored)
  features/<name>/   ui/ domain/ data/ — one folder per feature
  shared/            (create when needed) widgets used by >=2 features
test/                mirrors lib/ one-to-one
docs/adr/            architecture decisions
```

## Stack: Riverpod 3 (state + DI, no codegen), go_router, dio, drift,
shared_preferences, flutter_secure_storage, connectivity_plus,
freezed/json_serializable, intl.

## Dependency rule
`ui -> domain <- data`; `features/*` -> `core`; `app` -> `features`+`core`.
`core` imports nothing from `features`/`app`. A feature never imports another
feature's internals; share via `core` or `shared`, or route navigation.

## Non-negotiables
- No `TODO/FIXME/HACK`, no commented-out code (analyzer enforces `todo`).
- No hardcoded URLs/paths/timeouts/magic numbers: named constants or
  `AppConfig`. Secrets never in code or `--dart-define`.
- No swallowed errors. Map to `AppException`, return `Result`, log via
  `AppLogger` with cause + stack. Never log tokens/PII.
- Every async I/O has a timeout.
- Validate input at boundaries (API payloads, DB rows, deep links).
- Android only. No Firebase/store tooling; do not add iOS/web-specific code.
- All user-visible strings go in `lib/l10n/*.arb` (add key to vi AND en).
- API base URL comes only from `API_BASE_URL`; never hardcode endpoints hosts.
- Pin deps via `pubspec.lock` (committed). Justify every new dependency
  (license, maintenance, size); don't add one for a single helper.
- Each new behavior ships with a test; bug fixes ship with a regression test.
- Architecture change => new ADR in `docs/adr/`. Env/deploy change => README.
