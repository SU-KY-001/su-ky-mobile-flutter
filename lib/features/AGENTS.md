# AGENTS.md — lib/features/

One folder per feature: `lib/features/<feature>/`
```
ui/       <name>_screen.dart (View), <name>_view_model.dart (ViewModel)
domain/   entities, (optional) use cases — pure Dart, no Flutter imports
data/     <name>_repository.dart (+ impl), services, DTOs/mappers
```
Create `domain/`/`data/` only when the feature has them (reference feature
`home` is UI-only).

## Rules
- View: `ConsumerWidget`; renders ViewModel state, forwards events. No logic, no I/O.
- ViewModel: Riverpod `Notifier`/`AsyncNotifier` (+ provider in same file),
  no `BuildContext`/widgets. Gets repositories via `ref.watch(...)`. Exposes
  loading/error/data explicitly (`AsyncValue`). Use `autoDispose` by default.
- Repository: single source of truth; returns `Result<T>`; maps DTO -> domain;
  hides services. Abstract class in `domain/` or `data/`, so tests fake it.
- Service: wraps one external source (HTTP, sqflite); no business rules.
- No cross-feature imports of `ui/` or `data/`. Shared code -> `core/` or
  `shared/`.
- Tests: `test/features/<feature>/...` — ViewModel unit tests with
  `ProviderContainer(overrides: [...])` and fake repositories (happy path, empty, error, retryable error); widget test per
  screen's main flow.
- New feature checklist: folder, route in `app/router`, tests, no hardcoded
  strings/values.
