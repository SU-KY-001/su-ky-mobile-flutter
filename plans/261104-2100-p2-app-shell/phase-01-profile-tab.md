# Phase 1 - Tab Hồ sơ tối thiểu + l10n (task 2.4)

Context: [plan.md](./plan.md). Màn chưa gắn route (phase 2 gắn). Đọc `AGENTS.md` (root), `lib/core/AGENTS.md`, `lib/features/AGENTS.md` trước.

## Requirements
- `lib/features/profile/ui/profile_screen.dart` (`ConsumerWidget`, chỉ `ref.watch(sessionControllerProvider)`; không cần view model vì không có state riêng). Tạo riêng `domain/`/`data/` là **không** (chưa có nội dung thật, theo `AGENTS.md`).
- Khách (`!isAuthenticated`): thẻ biểu tượng người + tiêu đề "Chưa đăng nhập" + mô tả "Đăng nhập để đồng bộ tiến trình nghe, lưu quiz và tích luỹ XP." + `FilledButton` "Đăng nhập ngay" → `context.push(AppRoutes.login)` (đăng nhập xong `popOrGo` quay lại, xem phase 3).
- Đã đăng nhập: avatar chữ cái đầu của `user.name`, tên, email, nút "Đăng xuất" → `ref.read(sessionControllerProvider.notifier).signOut()` (không hộp thoại xác nhận, theo RN). `signOut` đã idempotent từ P1; đọc `session_controller.dart` để biết chữ ký thật.
- Dùng `AppPage` (không `bottom`, tab bar do shell lo) và token từ `AppDesign`/`Theme`. Không `Color(0x..)`, không số cứng: khoảng cách lấy từ `AppDesign`.
- Tách `profile_guest_card.dart`, `profile_user_card.dart` nếu `profile_screen.dart` > 150 dòng.
- ARB vi+en: `profileTitle` ("Hồ sơ cá nhân"/"Profile"), `profileGuestTitle`, `profileGuestMessage`, `profileSignInNow`, `profileSignOut`, cùng 3 nhãn tab mới `tabHistory` ("Lịch sử"/"History"), `tabPodcast` ("Podcast"/"Podcast"), `tabQuiz` ("Quiz"/"Quiz"). Nhãn tab Hồ sơ dùng key `profile` sẵn có ("Cá nhân"/"Profile").

## Related files
Tạo: `lib/features/profile/ui/{profile_screen,profile_guest_card,profile_user_card}.dart`. Sửa: `lib/l10n/app_vi.arb`, `lib/l10n/app_en.arb`. Đọc: `lib/features/auth/ui/session_controller.dart`, `lib/shared/design/app_design.dart`, `lib/shared/widgets/su_ke_widgets.dart` (`AppPage`).

## Todo
- [ ] ARB vi+en + `flutter gen-l10n`
- [ ] `ProfileScreen` (khách / đã đăng nhập)
- [ ] Tách file con nếu cần (< 250 dòng mỗi file)

## Success criteria
`flutter gen-l10n`, `dart format lib`, `flutter analyze` sạch; 3 lệnh grep/find ở "Verify" rỗng; không có chuỗi người dùng nào nằm ngoài ARB.

## Risks
- Không log email/tên. Không hiển thị token.
- Chưa có route nên màn chưa chạy được tới hết phase 2: chấp nhận.
