# AGENTS.md — su_ky_mobile (root)

Flutter app, feature-first MVVM (Flutter official architecture). Read nearest nested `AGENTS.md` before editing folder; it overrides this file.

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
`ui -> domain <- data`; `features/*` -> `core`; `app` -> `features`+`core`. `core` import nothing from `features`/`app`. Feature never import another feature internals; share via `core` or `shared`, or route navigation.

## Non-negotiables
- No `TODO/FIXME/HACK`, no commented-out code (analyzer enforces `todo`).
- No hardcoded URLs/paths/timeouts/magic numbers: named constants or `AppConfig`. Secrets never in code or `--dart-define`.
- No swallowed errors. Map to `AppException`, return `Result`, log via `AppLogger` with cause + stack. Never log tokens/PII.
- Every async I/O has timeout.
- Validate input at boundaries (API payloads, DB rows, deep links).
- Android only. No Firebase/store tooling; no iOS/web-specific code.
- All user-visible strings go in `lib/l10n/*.arb` (add key to vi AND en).
- API base URL only from `API_BASE_URL`; never hardcode endpoint hosts.
- Pin deps via `pubspec.lock` (committed). Justify every new dependency (license, maintenance, size); no add for single helper.
- Each new behavior ships with test; bug fixes ship with regression test.
- Architecture change => new ADR in `docs/adr/`. Env/deploy change => README.

## Enforced standards (each was violated once; review checks them)
Verify before "done": run commands under **Verify** below, all must be empty/green.

### Strings and l10n
- No user-visible literal in `.dart` under `lib/` (Vietnamese or English), including `Text`, `SnackBar`, `tooltip`, `semanticsLabel`, labels, dialogs. Use `context.l10n.<key>`; add key to BOTH `app_vi.arb` and `app_en.arb`.
- Dynamic text use ICU placeholders/plurals, never string concatenation.

### Colors, sizes, durations
- No `Color(0x...)` outside `app/theme` and `AppDesign`/`<feature>_colors.dart`. Prefer `Theme.of(context).colorScheme`; color used twice gets named token.
- No bare numbers for durations, delays, limits, step sizes: named `const`.
- `AppDesign` holds design tokens only (color, spacing, radius). Never data.

### State and logic placement
- Screen/business state live in `autoDispose` Riverpod `Notifier` with **immutable** state class (`final` fields, `copyWith`). Mutable fields in state or entity classes forbidden.
- `StatefulWidget`/`setState` only for ephemeral UI (animation, scroll, text controller, focus). Selection, filters, completion, timers = view model.
- `Notifier<AsyncValue<int>>` or any `AsyncValue` never loading/error is wrong: use plain value type.
- Entities in `domain/` pure Dart (no Flutter imports, no `IconData`/`Color`); UI maps keys/enums to icons and colors.
- Data from storage/network validated field by field at boundary (`Map<String, dynamic>` decoded into typed model there, never passed on).

### Mock and placeholder data
- Placeholder data live only in `lib/**/mock/` or `data/mock_*.dart`, named `Mock*`, typed, replaced when real API lands. Never in widget, `State`, or `AppDesign`. Mock UI text still from ARB.

### File size and structure
- `.dart` file stay <= 250 lines; split before it grow past that (extract section widgets into own files, one public widget per file).
- No giant `_buildX` methods returning big trees: extract widget class.
- Create `domain/`, `data/` only when feature has real content; no empty folders. First feature that talks to API adds them.

### Navigation
- Screens never receive route callbacks (`onBack`, `onSeries`, ...). They call `context.push/go(AppRoutes.x)`. Router only maps path -> screen with data params (ids). New route = constant in `app_routes.dart`.

### Dependencies and unused code
- Package or provider with zero consumers removed, not kept "for later". Exception: ADR names plan that adds its first consumer (currently Drift: `core/storage` + `databaseProvider`). Add new packages in change that first uses them.

### Tests
- Every new view model: happy path, empty, error. Every refactor keeps existing behavior tests green; delete tests that only pin wording or layout.
- Navigation assertions in widget tests use `router.routerDelegate.currentConfiguration.last.matchedLocation` (`routeInformationProvider.value` does not change on `push`).

### Verify
```sh
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
# must print nothing (only AppDesign tokens may match the color check):
grep -rnE "Color\(0x" lib --include=*.dart | grep -vE "app.theme|shared.design|_colors\.dart|l10n.gen"
grep -rnE "Text\((const )?['\"][^'\"$]*[A-Za-zÀ-ỹ]" lib --include=*.dart | grep -v "l10n.gen"
find lib -name '*.dart' -not -path '*/l10n/gen/*' -not -name '*.g.dart' | xargs wc -l | awk '$1>250 && $2!="total"'
```