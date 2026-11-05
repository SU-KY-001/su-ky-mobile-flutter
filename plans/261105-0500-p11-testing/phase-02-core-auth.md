---
status: pending
---

# Phase 2 - Test hạ tầng + Auth (11.1a)

## Files (tất cả trong `test/`, phản chiếu `lib/`)
- Sửa `test/core/network/dio_factory_test.dart` (bỏ `ValidationException`, theo `ApiException` hiện tại).
- Mới/sửa: `test/core/network/` (`mapDioException`: 2 dạng lỗi của API, bảng retryable vs không; timeout; lỗi kết nối), `AuthInterceptor` (gắn Bearer khi có token; 401 xoá phiên; **không** xoá phiên khi sign-in sai mật khẩu), `test/core/auth/` (`TokenStore` đọc/ghi/xoá với kho giả).
- `test/features/auth/`: `AuthRepository` (sign-in lấy token từ header `set-auth-token`, sign-out, `/api/me`), `SessionController` (hydrate, đăng nhập, đăng xuất, 401 -> khách), form view model hiện tại (mật khẩu >= 8 ký tự, ánh xạ lỗi, chống bấm đúp). Xoá `login_view_model_test.dart` (file nguồn không còn); viết lại cho view model đang có.
- Dùng Dio với `HttpClientAdapter` giả, không gọi mạng.

## Cách làm
Đọc `lib/core/` và `lib/features/auth/` trước để bám đúng tên hiện tại. Mỗi lỗi hành vi (khác với test lỗi thời) -> `BUG-nn` + `skip`.

## Xong khi
`flutter test test/core test/features/auth` xanh; `flutter analyze test/core test/features/auth` 0 lỗi; mục "Test cũ" và "Bug" của report đã cập nhật.
