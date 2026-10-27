# ADR 0001: Feature-first MVVM, Flutter official layering

- Status: accepted
- Date: 2026-10-27

## Context
Need a maintainable structure for a multi-developer mobile app. Flutter's
official app-architecture guide (https://docs.flutter.dev/app-architecture/guide)
recommends MVVM with UI (View + ViewModel) and Data (Repository + Service)
layers, optional Domain layer. Community consensus (2026) pairs this with
feature-first foldering.

## Decision
- `lib/features/<feature>/{ui,domain,data}` — group by feature, not by type.
- `lib/core` for cross-feature infrastructure; `lib/app` for wiring.
- State/DI: Riverpod 3 (no codegen). ViewModels are `Notifier`s.
- Network: dio, base URL from `API_BASE_URL`. Storage: drift (offline-first),
  shared_preferences, flutter_secure_storage. Models: freezed + json_serializable.
- i18n: intl/ARB, vi default. Platform: Android only; no store/Firebase.
- Errors: `Result<T>` + sealed `AppException`; no exceptions across layers.
- Config: `--dart-define=ENV=dev|staging|prod`, parsed once, fail-fast.
- Routing: `go_router`, all routes in `app/router`.

## Consequences
+ Features removable/testable in isolation; layering matches official docs.
- Generated code (drift/freezed/l10n) is git-ignored; clone needs build_runner.

## Rollback
Pure convention; no runtime coupling to undo.
