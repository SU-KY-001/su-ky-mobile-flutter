# Phase 5 - Cổng khách (task 4.7)

Context: [plan.md](./plan.md). Cần phase 3 (`PlayOutcome.needsLogin`) và phase 4 (các điểm vào Phát). Đọc `lib/app/router/app_routes.dart` (`loginFor`, `safeReturnTo`), `lib/features/auth/ui/login_screen.dart` (sau đăng nhập: `returnTo == null` thì `popOrGo(home)`, tức là quay lại màn trước), `session_controller.dart`.

## Requirements
- `lib/shared/audio/play_gate.dart`: hàm dùng chung `Future<void> playFromUi(BuildContext, WidgetRef, String slug, {String? narrationId})`: gọi `playEpisode`; `PlayOutcome.needsLogin` → `showDialog` (nút "Để sau" và "Đăng nhập"); bấm Đăng nhập thì `context.push(AppRoutes.login)` (push, không `go`, để Back về đúng màn cũ). Mọi điểm vào Phát ở phase 4 gọi hàm này thay vì gọi controller trực tiếp; thành công thì mở `AppRoutes.player`. Dialog dựng bằng widget riêng `LoginRequiredDialog` (`lib/shared/widgets/`), chuỗi từ ARB.
- Controller: khi `needsLogin`, lưu `pendingPlay = (slug, narrationId, requestedAt)`. `ref.listen(sessionControllerProvider)`: khi chuyển sang đã đăng nhập và `pendingPlay` còn trong `AudioDefaults.pendingPlayTtl` thì `playEpisode` đúng tập đó rồi xoá `pendingPlay`; quá hạn thì chỉ xoá. Cũng xoá `pendingPlay` khi đăng xuất hoặc khi có `playEpisode` khác.
- Sau đăng nhập, `LoginScreen` đóng (pop) về màn nơi bấm Phát; việc tự phát xảy ra qua listener, `LoginScreen` không import audio.
- Nếu người dùng đã đăng nhập rồi vào Player qua deep link `/player` khi chưa có tập: dùng trạng thái rỗng của phase 4, không cần cổng.
- ARB (vi+en): `loginRequiredTitle`, `loginRequiredMessage` ("Đăng nhập để nghe đầy đủ câu chuyện và lưu tiến trình cá nhân."), `loginRequiredLater`, `loginRequiredAction`.

## Risks / security
- Nếu người dùng đăng nhập bằng tài khoản khác với lần bấm Phát: vẫn phát `pendingPlay` trong TTL (tập không phụ thuộc tài khoản); chấp nhận.
- Không lưu `pendingPlay` ra đĩa (chỉ trong bộ nhớ), nên kill app là mất.
- Khách không gọi `playback` ở bất kỳ nhánh nào (API trả 200 cho khách nhưng quy tắc app là chặn).

## Todo
- [x] `LoginRequiredDialog` + ARB
- [x] `playFromUi` và đổi 4 điểm vào Phát (series tile, nghe từ đầu, Home, thẻ tập kế ở Player) sang hàm này
- [x] `pendingPlay` + listener phiên + TTL + xoá khi đăng xuất/phát tập khác
- [x] `flutter analyze` sạch; 3 lệnh grep/find rỗng
