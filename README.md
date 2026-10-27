# Sử Ký (su_ky_mobile)

Flutter mobile app. Architecture: feature-first MVVM — see
[docs/adr/0001-architecture.md](docs/adr/0001-architecture.md) and
[AGENTS.md](AGENTS.md).

## Requirements
Flutter 3.47+ / Dart 3.13+.

## Run
```sh
flutter pub get
cp env/dev.example.json env/dev.json      # set API_BASE_URL
dart run build_runner build --delete-conflicting-outputs   # drift/freezed/json
flutter gen-l10n
flutter run --dart-define-from-file=env/dev.json
```
Android only. Generated files (`*.g.dart`, `*.freezed.dart`, `lib/l10n/gen/`) are git-ignored; regenerate after clone.

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
