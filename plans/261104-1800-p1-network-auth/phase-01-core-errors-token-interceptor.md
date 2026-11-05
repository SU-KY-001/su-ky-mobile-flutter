# Phase 1 — Lỗi API + TokenStore + Interceptor (tasks 1.1, 1.2, 1.3)

Context: [plan.md](./plan.md). Đọc `lib/core/AGENTS.md` trước.

## Requirements
- Phân biệt lỗi API theo `error_code`/`code`, không theo `message`.
- Token nằm trong secure storage, không bao giờ trong SharedPreferences hay log.
- Request gắn Bearer; 401 có Bearer thì xoá phiên.

## Related files
- Sửa: `lib/core/error/app_exception.dart`, `lib/core/network/dio_factory.dart`, `lib/core/di/providers.dart`
- Tạo: `lib/core/auth/session_user.dart`, `lib/core/storage/token_store.dart`, `lib/core/network/auth_interceptor.dart`, `env/accounts.example.json` (đã tạo; kiểm còn tồn tại)
- `env/accounts.local.json` (gitignored, đã tồn tại) chứa credential thử; **không** đưa vào `env/dev.json` (`--dart-define-from-file` nhúng vào APK).

## Implementation steps
1. **`ApiException`** trong `app_exception.dart`: `final class ApiException extends AppException { const ApiException(super.message, {required this.statusCode, this.errorCode, super.cause}); final int statusCode; final String? errorCode; @override bool get isRetryable => retryableErrorCodes.contains(errorCode); }` và `const retryableErrorCodes = {'RATE_LIMITED','IDEMPOTENCY_REQUEST_IN_PROGRESS','MEDIA_PROVIDER_UNAVAILABLE'};` cùng file. 5xx là `NetworkException` (retryable) nên `ApiException` chỉ cần xét mã.
2. **`mapDioException`** nhánh `badResponse`: 5xx giữ `NetworkException('Server error $status')`; 4xx trả `ApiException` với `errorCode = body['error_code'] ?? body['code']` (chỉ nhận `String`), `message = body['message']` (chỉ `String`, không thì `'Request rejected $status'`); body không phải `Map` → `errorCode` null. Không log body.
3. `ValidationException` bị xoá (không còn consumer: 4xx giờ là `ApiException`, validation client-side nằm ở `AuthFormViewModel`). `grep -rn "ValidationException" lib` phải rỗng.
4. **`SessionUser`** thuần Dart ở `lib/core/auth/session_user.dart` (core không import features): `final class SessionUser { const SessionUser({required this.id, required this.name, required this.email}); }` + `==`/`hashCode` theo 3 trường.
5. **`TokenStore`** `lib/core/storage/token_store.dart`: `TokenStore(FlutterSecureStorage)`. Khoá `auth.token`, `auth.user` (JSON `{id,name,email}`). API: `String? get current` (cache đồng bộ cho interceptor); `Future<StoredSession?> load()` (đọc cả hai khoá, nạp cache; thiếu một khoá → `null`; JSON hỏng hoặc thiếu trường `String` không rỗng → xoá cả hai, `AppLogger.error`, trả `null`; lỗi storage → log, trả `null`); `Future<void> save(String token, SessionUser user)` (lỗi → ném `StorageException`); `Future<void> clear()` (xoá khoá + cache, rồi `_cleared.add(null)`); `Stream<void> get onCleared` (`StreamController<void>.broadcast`); `void dispose()`. `typedef StoredSession = ({String token, SessionUser user})`. Mọi I/O `.timeout(_storageTimeout)` với `const _storageTimeout = Duration(seconds: 10)`.
6. `providers.dart`: `final tokenStoreProvider = Provider<TokenStore>((ref) { final s = TokenStore(ref.watch(secureStorageProvider)); ref.onDispose(s.dispose); return s; });`
7. **`AuthInterceptor`** `lib/core/network/auth_interceptor.dart`: `onRequest`: có `_tokens.current` và request chưa có `Authorization` → đặt `Bearer <token>`. `onError`: `statusCode == 401` **và** request đã mang Bearer **và** path không bắt đầu bằng hằng `_credentialPaths = ['/api/auth/sign-in', '/api/auth/sign-up']` → `await _tokens.clear()` rồi `handler.next(e)`.
8. `createDio(AppConfig config, {TokenStore? tokens})`: thêm `AuthInterceptor` **trước** interceptor map lỗi hiện có. `dioProvider` truyền `ref.watch(tokenStoreProvider)`. Grep `createDio(` để chắc mọi chỗ gọi còn hợp lệ.

## Todo
- [x] ApiException + retryableErrorCodes
- [x] mapDioException 2 dạng lỗi
- [x] SessionUser (core)
- [x] TokenStore + tokenStoreProvider
- [x] AuthInterceptor + createDio/dioProvider

## Success criteria
`flutter analyze` sạch; `grep -rn "ValidationException" lib` không còn chỗ nào dựa vào 4xx; token không xuất hiện ở bất kỳ `AppLogger` call.

## Risks / security
- Không log token, email, mật khẩu, body phản hồi.
- 401 từ sign-in sai mật khẩu không được xoá phiên (đã loại bằng `_credentialPaths`).
