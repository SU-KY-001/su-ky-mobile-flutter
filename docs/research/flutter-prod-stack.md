# Research: Flutter prod stack (React dev view)

Date: 2026-10-27. Sources: search snippets only (not deep-read), pub.dev knowledge. Version numbers NOT verified: run `flutter pub add <pkg>` to get current.

## React -> Flutter map

| Concern | React world | Flutter prod pick | Status here |
|---|---|---|---|
| UI | JSX + components | Widgets (built in) | have |
| Routing | react-router | `go_router` | installed |
| State | Redux/Zustand/Query | `flutter_riverpod` (default) or `flutter_bloc` (big/strict teams) | not yet; ChangeNotifier MVVM |
| Server state/cache | TanStack Query | Riverpod `AsyncNotifier` (+ repository cache) | n/a |
| HTTP | axios/fetch | `dio` (interceptors, timeout, cancel) | not yet |
| Models/JSON | zod/TS types | `freezed` + `json_serializable` (build_runner) or `dart_mappable` | not yet |
| Local KV | localStorage | `shared_preferences` | not yet |
| Secrets/tokens | httpOnly cookie | `flutter_secure_storage` (Keychain/Keystore) | not yet |
| Local DB | IndexedDB | `drift` (typed SQL, migrations); `sqflite` is raw SQL | sqflite installed |
| Env/flavors | .env + vite modes | `--dart-define-from-file` + Android flavors | ENV define done |
| i18n | i18next | `flutter_localizations` + `intl` (ARB files) | not yet |
| Crash/errors | Sentry | `sentry_flutter` or Firebase Crashlytics | AppLogger hook only |
| Analytics/push | GA/FCM | `firebase_analytics`, `firebase_messaging` | not yet |
| Auth | NextAuth etc | backend JWT + secure storage, or `firebase_auth` | not yet |
| Lint | eslint | `flutter_lints` (have) / `very_good_analysis` (stricter) | have |
| Unit/widget test | jest/RTL | `flutter_test` + `mocktail` | flutter_test only |
| E2E | Playwright/Cypress | `integration_test` (or `patrol`) | not yet |
| CI/CD | GH Actions | GH Actions or Codemagic + `fastlane` for signing/store upload | not yet |
| Release | Vercel | Play Console / App Store Connect, staged rollout | n/a |
| Remote flags | LaunchDarkly | `firebase_remote_config` | not yet |
| Dep updates | Renovate | Dependabot/Renovate (pub supported) | not yet |

## Decisions (opinionated)

1. State: Riverpod. Consensus 2026 for new apps; Bloc if team wants enforced event/state ceremony. Provider = legacy-ish (same author as Riverpod).
2. DB: drift if relational/offline-first; else `shared_preferences` + secure storage only. Avoid Hive/Isar originals: reported stalled (use `hive_ce`/`isar_community` forks only if needed). sqflite already installed -> fine for simple, drift when schema grows.
3. Models: freezed + json_serializable = standard but needs `build_runner`; skip until >~10 DTOs.
4. Crash reporting is the first prod must-have to add.
5. Don't add everything now (YAGNI). Add per feature need.

## Minimum "prod-ready" set to add next
`flutter_riverpod`, `dio`, `flutter_secure_storage`, `shared_preferences`, `sentry_flutter`, dev: `mocktail`, `integration_test`, `build_runner`+`freezed`+`json_serializable`, i18n via `intl`.

## Unresolved
- Backend/auth type? (decides dio vs firebase, auth package)
- Target stores/iOS? (decides fastlane, signing)
- Offline-first needed? (decides drift)
- Riverpod vs Bloc team preference.
- Versions not verified.

## Sources
- https://docs.flutter.dev/app-architecture/guide
- https://docs.flutter.dev/deployment/cd
- https://fluttergo.ai/blog/flutter-local-database-2026/
- https://flutterstudio.dev/blog/bloc-vs-riverpod.html
- https://samioda.com/en/blog/flutter-state-management-2026
