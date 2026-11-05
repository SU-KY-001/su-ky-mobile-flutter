# AGENTS.md — lib/core/

Cross-feature infrastructure. MUST NOT import `features/` or `app/`.

| Folder | Purpose | Rules |
|---|---|---|
| `config/` | `AppConfig`, `AppEnvironment` | Immutable, build-time, parsed once, fail fast. No secrets. |
| `error/` | `AppException` (sealed), `Result<T>` | New failure kind = new sealed subtype with correct `isRetryable`. |
| `di/` | `providers.dart`: app-wide Riverpod providers | `appConfigProvider`/`sharedPreferencesProvider` are overridden in `main`/tests. Feature providers live in the feature. |
| `network/` | `createDio`, `mapDioException` | One `Dio` via `dioProvider`. Timeouts on every request. Repositories catch `DioException`, return `Err(e.error as AppException)`. Retry only `isRetryable`, bounded backoff. |
| `storage/` | `TokenStore` | Tokens/credentials only, via `secureStorageProvider`; never in prefs. Non-sensitive prefs use `sharedPreferencesProvider`. No local database (`flutter_secure_storage` + `shared_preferences` only, ADR 0012). |
| `logging/` | `AppLogger` | Only logging sink; no `print`. Swap crash reporter here. |

## Online-only rule
There is no local database: reads go to the API, tokens and light preferences
are the only persisted state. `isOnlineProvider` is a hint, not proof of
reachability: always handle `NetworkException`.
