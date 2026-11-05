# Phase 2 — AuthRepository + SessionController (tasks 1.4, 1.5)

Context: [plan.md](./plan.md). Cần phase 1 (`ApiException`, `TokenStore`, `SessionUser`, `tokenStoreProvider`).

## Requirements
- Sign-in/up/out và `/api/me` qua một repository trả `Result`, không ném lỗi qua ranh giới lớp.
- Trạng thái phiên toàn app, hydrate lúc khởi động; mất mạng không làm đăng xuất.

## Related files
- Tạo: `lib/features/auth/data/auth_repository.dart` (+ `lib/features/auth/data/auth_dtos.dart` nếu file > 250 dòng), `lib/features/auth/ui/session_controller.dart`
- Sửa: `lib/app/app.dart`

## Implementation steps
1. `auth_repository.dart`: `typedef AuthSession = ({String token, SessionUser user});` `abstract class AuthRepository { Future<Result<AuthSession>> signIn(String email, String password); Future<Result<AuthSession>> signUp(String name, String email, String password); Future<Result<SessionUser>> me(); Future<Result<void>> signOut(); }`.
2. `ApiAuthRepository(Dio)`; hằng path: `/api/auth/sign-in/email`, `/api/auth/sign-up/email`, `/api/me`, `/api/auth/sign-out`. Gửi `email.trim()`, `name.trim()`.
3. Parse token: `response.headers.value('set-auth-token')` nếu không rỗng, không thì `body['token']` là `String` không rỗng; thiếu cả hai → `Err(UnknownException('Missing session token'))`. Parse user: `body['user']` phải là `Map` có `id`,`name`,`email` đều `String` không rỗng, sai → `Err(UnknownException('Malformed user payload'))`. `me()` dùng cùng validator trên `body['user']`.
4. Bắt `DioException` → `Err(e.error is AppException ? e.error as AppException : mapDioException(e))`; lỗi khác → `Err(UnknownException(..., cause))` + `AppLogger.error` (không log email/mật khẩu/token). `signOut`: `POST` body `<String, Object>{}`; trả `Err` nếu server lỗi.
5. `final authRepositoryProvider = Provider<AuthRepository>((ref) => ApiAuthRepository(ref.watch(dioProvider)));`
6. `session_controller.dart`: `class SessionState { const SessionState({this.hydrated = false, this.user}); final bool hydrated; final SessionUser? user; bool get isAuthenticated => user != null; copyWith }` (không `AsyncValue`). `NotifierProvider<SessionController, SessionState>` **không autoDispose** (state toàn app; comment 1 dòng nêu lý do). `build()`: `final sub = ref.read(tokenStoreProvider).onCleared.listen((_) => state = SessionState(hydrated: state.hydrated)); ref.onDispose(sub.cancel); Future.microtask(hydrate); return const SessionState();`.
7. `hydrate()`: `load()`; null → `state = SessionState(hydrated: true)`, `AppLogger.info('Session hydrated: guest')`. Có phiên → `state = SessionState(hydrated: true, user: cached)` ngay, rồi `repo.me()`: `Ok` → `tokens.save(token, user)` + cập nhật state; `Err(ApiException)` 401 → interceptor đã `clear()` (state tự về guest); `Err` khác (mạng) → giữ phiên cache, log. Cuối: `AppLogger.info('Session hydrated: authenticated|guest')`, không PII.
8. `signIn(email,pw)` / `signUp(name,email,pw)`: gọi repo; `Ok(session)` → `await tokens.save(...)`, `state = SessionState(hydrated: true, user: session.user)`, trả `Ok(null)`; `Err` trả nguyên; `StorageException` từ `save` → trả `Err`.
9. `signOut()`: `repo.signOut()` (log lỗi nếu có), **luôn** `await tokens.clear()`; trả `Result<void>` của lệnh gọi API.
10. `app.dart` `_AppState.initState`: `ref.read(sessionControllerProvider);` (không `watch`, tránh rebuild `MaterialApp`).

## Todo
- [x] AuthRepository + provider
- [x] SessionController (hydrate/signIn/signUp/signOut)
- [x] Khởi động hydrate trong `app.dart`

## Success criteria
`flutter analyze` sạch; mọi `Err` dùng `AppException`; không có `AsyncValue` giả trong `SessionState`.

## Risks / security
- Chỉ 401 (qua interceptor) mới đăng xuất khi hydrate; lỗi mạng giữ phiên.
- `signOut` luôn xoá token cục bộ dù server lỗi.
