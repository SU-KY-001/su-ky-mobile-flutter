# ADR 0012: Remove Drift and unused code generation

- Status: accepted
- Date: 2026-11-05

## Context

The scaffold added Drift as an offline-first store, but `AppDatabase` declared
`@DriftDatabase(tables: [])`: no tables were ever created and
`databaseProvider` had no consumer. No feature needs SQLite — the app is
online-only, and per-episode resume positions live in `SharedPreferences`
(ADR 0007) while tokens live in secure storage (ADR 0003). Reviewing the
rule "a package or provider with zero consumers is removed, not kept for
later" left two honest options: remove Drift, or write an ADR naming the plan
that adds its first table. No such plan exists.

`freezed`, `freezed_annotation`, `json_annotation` and `json_serializable`
were also declared but imported nowhere; DTOs are decoded by hand-written
parsers at the API boundary (ADR 0005). With those generators gone, no source
in `lib/` or `test/` uses `part '*.g.dart'`, so `build_runner` had no work
left. `path` was a direct dependency only for Drift's file path and remains
available transitively (for example through `just_audio`).

## Decision

- Delete `lib/core/storage/app_database.dart` (and its generated file) and
  `databaseProvider`.
- Remove from `pubspec.yaml`: `drift`, `drift_flutter`, `drift_dev`,
  `freezed`, `freezed_annotation`, `json_annotation`, `json_serializable`,
  `path` and `build_runner`.
- Keep `lib/core/storage/token_store.dart`, which is the only storage the app
  uses besides preferences.
- Remove the `build_runner` step from the setup commands in `README.md` and
  `AGENTS.md`.

## Consequences

+ `pubspec.lock` loses 44 packages (analyzer/build toolchain, SQLite
  bindings, generators), so resolution and builds are smaller.
+ No generated model/database code to regenerate or keep in sync.
- Adding local relational storage or generated models later means adding the
  packages and a new ADR in the same change that introduces the first
  consumer; the dependency is not kept "for later".
- Hand-written parsers must stay strict and validated at the boundary.

## Adding it back

When a feature first needs SQLite, add `drift`/`drift_dev` (and
`build_runner`) in that change, define the first table, and write a
superseding ADR. Re-adding a package with no consumer is not allowed.

## Rollback

Restore the deleted `AppDatabase`, `databaseProvider`, package entries and the
`build_runner` command from git history; nothing else depended on them.
