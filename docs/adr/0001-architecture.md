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
- Network: dio, base URL from `API_BASE_URL`. Storage:
  shared_preferences, flutter_secure_storage. Models are hand-written and
  validated at the boundary; no code generation (ADR 0012).
- i18n: intl/ARB, vi default. Platform: Android only; no store/Firebase.
- Errors: `Result<T>` + sealed `AppException`; no exceptions across layers.
- Config: `--dart-define=ENV=dev|staging|prod`, parsed once, fail-fast.
- Routing: `go_router`, all routes in `app/router`.

## Consequences
+ Features removable/testable in isolation; layering matches official docs.
- Generated l10n (`lib/l10n/gen/`) is git-ignored; clone needs `flutter gen-l10n`.

## Rollback
Pure convention; no runtime coupling to undo.
