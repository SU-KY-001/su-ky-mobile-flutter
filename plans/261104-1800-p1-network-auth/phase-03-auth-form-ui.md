# Phase 3 — Form Đăng nhập/Đăng ký + l10n (tasks 1.0, 1.6)

Context: [plan.md](./plan.md). Cần phase 2 (`sessionControllerProvider`).

## Requirements
- Một màn, chuyển qua lại Đăng nhập ↔ Đăng ký; ô tên chỉ khi Đăng ký.
- Mật khẩu 8–128 ký tự, tên 2–100, email hợp lệ; chống bấm đúp; lỗi hiển thị bằng chuỗi ARB.

## Related files
- Đổi tên + sửa: `lib/features/auth/ui/login_view_model.dart` → `auth_form_view_model.dart`
- Sửa: `lib/features/auth/ui/login_screen.dart` (hiện 207 dòng; tách để < 250)
- Tạo: `lib/features/auth/ui/auth_fields.dart`, `lib/features/auth/ui/auth_mode_footer.dart`
- Sửa: `lib/l10n/app_vi.arb`, `lib/l10n/app_en.arb`

## Implementation steps
1. `auth_form_view_model.dart`: `enum AuthMode { signIn, signUp }`; `enum AuthFormError { invalidInput, wrongCredentials, emailTaken, network, unknown }`; hằng `minPasswordLength = 8`, `maxPasswordLength = 128`, `minNameLength = 2`, `maxNameLength = 100`; giữ `_emailPattern`.
2. State bất biến `AuthFormState{ mode, name, email, password, obscured, submitting, error }` (không `AsyncValue`/`requireValue`). `autoDispose Notifier<AuthFormState>` tên `AuthFormViewModel`, provider `authFormViewModelProvider`. `setMode(AuthMode)` giữ email, xoá `error` và `password`.
3. `Future<bool> submit()`: nếu `submitting` trả `false`. Hợp lệ khi email khớp, mật khẩu 8–128, và (signUp) tên đã `trim` 2–100; sai → `error = invalidInput`, trả `false`, không gọi mạng. Hợp lệ → `submitting = true, error = null` → `sessionController.signIn/signUp` → `Ok` trả `true`; `Err(ApiException)` có `errorCode == 'INVALID_EMAIL_OR_PASSWORD'` → `wrongCredentials`; `errorCode` bắt đầu `USER_ALREADY_EXISTS` → `emailTaken`; `NetworkException` → `network`; còn lại → `unknown`. Luôn `submitting = false` ở cuối.
4. `login_screen.dart`: tách `auth_fields.dart` (ô tên/email/mật khẩu + hiện/ẩn) và `auth_mode_footer.dart` (chuyển Đăng nhập ↔ Đăng ký; nút "Đăng ký miễn phí" hiện có chuyển `mode` thay vì `notice`). Tiêu đề/phụ đề/nút theo `mode`; nút bị vô hiệu + `CircularProgressIndicator` nhỏ khi `submitting`; lỗi dưới form theo `AuthFormError`. Thành công: `if (ok && context.mounted) context.popOrGo(AppRoutes.home);` (thay `go(home)`; trả khách về màn đã mở login). Giữ nguyên nút Google và "Quên mật khẩu" (vẫn `demoNotice`, RN không có).
5. ARB vi/en (rồi `flutter gen-l10n`). Sửa `invalidCredentials`: vi `"Nhập email hợp lệ và mật khẩu từ 8 ký tự."` / en `"Enter a valid email and a password of at least 8 characters."`. Thêm:
   - `authSignUpHeading`: `"Tạo tài khoản Sử Ký"` / `"Create your Su Ke account"`
   - `authSignUpSubtitle`: `"Đăng ký để đồng bộ tiến trình nghe và lưu bộ câu hỏi."` / `"Sign up to sync your listening progress and save quizzes."`
   - `authSignUpAction`: `"Đăng ký & Tiếp tục nghe"` / `"Sign up & keep listening"`
   - `name`: `"Tên của bạn"` / `"Your name"`; `nameHint`: `"Nguyễn Văn A"` / `"Jane Doe"`
   - `haveAccount`: `"Đã có tài khoản?"` / `"Already have an account?"`; `signIn`: `"Đăng nhập"` / `"Sign in"`
   - `authWrongCredentials`: `"Sai email hoặc mật khẩu."` / `"Wrong email or password."`
   - `authEmailTaken`: `"Email này đã được đăng ký."` / `"This email is already registered."`
   - `authNetworkError`: `"Không kết nối được máy chủ. Thử lại sau."` / `"Cannot reach the server. Try again."`
   - `authUnknownError`: `"Có lỗi xảy ra. Thử lại sau."` / `"Something went wrong. Try again."`
6. `grep -rn "loginViewModelProvider\|LoginViewModel\|LoginState\|login_view_model" lib` rồi cập nhật mọi tham chiếu (dự kiến chỉ `login_screen.dart`). Không đụng `test/`.

## Todo
- [x] AuthFormViewModel (state bất biến, submit, ánh xạ lỗi)
- [x] Tách login_screen.dart (< 250 dòng mỗi file)
- [x] ARB vi+en, `flutter gen-l10n`
- [x] Không còn tham chiếu `login_view_model` trong `lib/`

## Success criteria
`flutter gen-l10n`, `dart format lib`, `flutter analyze` sạch; 3 lệnh grep/find ở "Verify" của `AGENTS.md` rỗng (không chuỗi cứng, không màu cứng, không file > 250 dòng).

## Risks / security
- Không đặt mật khẩu vào log hay vào state sau khi submit thành công ngoài cần thiết; `autoDispose` dọn form khi rời màn.
- Chuỗi lỗi chỉ từ ARB, không hiển thị `message` thô của server.
