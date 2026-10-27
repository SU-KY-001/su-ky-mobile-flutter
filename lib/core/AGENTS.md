# AGENTS.md — lib/core/

Cross-feature infrastructure. MUST NOT import `features/` or `app/`.

| Folder | Purpose | Rules |
|---|---|---|
| `config/` | `AppConfig`, `AppEnvironment` | Immutable, build-time, parsed once, fail fast. No secrets. |
| `error/` | `AppException` (sealed), `Result<T>` | New failure kind = new sealed subtype with correct `isRetryable`. |
| `di/` | `providers.dart`: app-wide Riverpod providers | `appConfigProvider`/`sharedPreferencesProvider` are overridden in `main`/tests. Feature providers live in the feature. |
| `network/` | `createDio`, `mapDioException` | One `Dio` via `dioProvider`. Timeouts on every request. Repositories catch `DioException`, return `Err(e.error as AppException)`. Retry only `isRetryable`, bounded backoff. |
| `storage/` | drift `AppDatabase` | Add tables to `@DriftDatabase`, bump `schemaVersion` + migration; no destructive migration without backup plan. Tokens -> `secureStorageProvider`; prefs -> `sharedPreferencesProvider`; never tokens in prefs. |
| `logging/` | `AppLogger` | Only logging sink; no `print`. Swap crash reporter here. |

## Offline-first rule
Repository reads local drift first, refreshes from API when `isOnlineProvider`
is true, writes locally then syncs. `isOnlineProvider` is a hint, not proof of
reachability: always handle `NetworkException`.

After editing drift tables/freezed/json models run build_runner (see root).
