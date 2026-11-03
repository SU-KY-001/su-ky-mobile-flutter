# 0003 — Auth and session

Sign-in, sign-up and sign-out call the real API (`/api/auth/sign-in/email`,
`/api/auth/sign-up/email`, `/api/auth/sign-out`) through `AuthRepository`, which
returns `Result`. The base URL comes only from `API_BASE_URL`.

The Bearer token is read from the `set-auth-token` response header, falling back
to `body.token`. It lives in `flutter_secure_storage` via `TokenStore` with the
cached `{id, name, email}`; never in SharedPreferences. `TokenStore.current` is a
synchronous cache so the Dio `AuthInterceptor` can attach `Authorization`
without awaiting storage.

A 401 on a request that carried a Bearer token clears the stored session and
emits `TokenStore.onCleared`; `SessionController` then drops to guest. Sign-in
and sign-up paths are excluded: a wrong password is also a 401 and must not wipe
an unrelated session.

On start `SessionController.hydrate` restores the cached user immediately, then
revalidates with `GET /api/me`. Only a 401 signs out; offline or server errors
keep the cached session. `signOut` always clears local state, even if the server
call fails.

API 4xx errors map to `ApiException(statusCode, errorCode)`. The code is read
from `error_code` (general endpoints) or `code` (`/api/auth/*`); callers branch
on it, never on `message`. Retryable codes: `RATE_LIMITED`,
`IDEMPOTENCY_REQUEST_IN_PROGRESS`, `MEDIA_PROVIDER_UNAVAILABLE`, plus 5xx and
network errors.

Passwords are 8–128 characters and names 2–100, matching the API schema.
Test credentials stay in the gitignored `env/accounts.local.json`, never in
`--dart-define-from-file`.
