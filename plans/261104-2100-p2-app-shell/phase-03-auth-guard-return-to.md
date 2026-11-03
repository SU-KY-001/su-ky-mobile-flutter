# Phase 3 - Auth guard + returnTo (task 2.3)

Context: [plan.md](./plan.md). Cần phase 2 (`routerProvider`).

## Requirements
- `AppRoutes.loginFor(String? returnTo)` → `Uri(path: login, queryParameters: {'returnTo': ...}).toString()` (không có `returnTo` thì trả `login`).
- `AppRoutes.safeReturnTo(String? value)`: trả `value` nếu bắt đầu `/`, không bắt đầu `//`, không bắt đầu `/login`; ngược lại `null` (chống open-redirect và vòng lặp; deep link là ranh giới dữ liệu theo `AGENTS.md`).
- `lib/app/router/auth_guard.dart`: `GoRouterRedirect authGuard(Ref ref)` đọc `sessionControllerProvider`: chưa `hydrated` → `null` (không redirect, RN không chặn bằng splash); khách → `AppRoutes.loginFor(state.uri.toString())`; đã đăng nhập → `null`.
- `routerProvider` thêm `refreshListenable`: `ValueNotifier<int>` tăng khi `ref.listen(sessionControllerProvider, ...)` đổi; `ref.onDispose` dispose notifier. Nhờ đó guard chạy lại sau hydrate xong và khi 401 xoá phiên (khách đang ở quiz bị đưa sang login rồi quay lại sau khi đăng nhập).
- Gắn `redirect: authGuard(ref)` **chỉ** cho route quiz (API `GET /api/episodes/{slug}/quiz` trả 401 cho khách, đã xác minh ở P0). Không gắn cho Profile/Series/Search/Missions: missions và player xử lý ở màn riêng (P4.7, P7).
- Router truyền `LoginScreen(returnTo: AppRoutes.safeReturnTo(state.uri.queryParameters['returnTo']))`: là tham số dữ liệu, không phải callback điều hướng.
- `login_screen.dart`: đăng nhập/đăng ký thành công → có `returnTo` thì `context.canPop() ? context.pushReplacement(returnTo) : context.go(returnTo)` (giữ ngăn xếp phía dưới nếu login được push), không có thì `context.popOrGo(AppRoutes.home)`. Nút đóng/back → `context.popOrGo(AppRoutes.home)` (bỏ ý định, theo RN `pendingPlay` bị loại).
- Không thêm helper `requireLogin()` ở phase này (chưa có consumer; P4.7 tạo cùng chỗ dùng).

## Related files
Tạo: `lib/app/router/auth_guard.dart`. Sửa: `lib/app/router/{app_routes,app_router}.dart`, `lib/features/auth/ui/login_screen.dart` (hiện 100–150 dòng, kiểm còn dưới 250).

## Todo
- [ ] `loginFor`, `safeReturnTo`
- [ ] `authGuard` + `refreshListenable` trong `routerProvider`
- [ ] Route quiz dùng guard; route login nhận `returnTo`
- [ ] `LoginScreen(returnTo)` và đường thoát

## Success criteria
`flutter analyze` sạch; 3 lệnh grep/find ở "Verify" rỗng; `safeReturnTo` từ chối `//evil.com`, `login`, `/login?x`, rỗng, `null` (kiểm bằng đọc code, test viết ở P11.1d).

## Risks
- `go_router` redirect chạy lại khi `refreshListenable` đổi: cần chắc guard không gây vòng lặp (login không có guard, `safeReturnTo` loại `/login`).
- `pushReplacement` trả `Future`; không `await` trong callback UI.
- Không có test: hồi quy chỉ lộ ở P11.
