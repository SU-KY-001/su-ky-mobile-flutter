# P12 - Lỗi trạng thái UI sau thao tác người dùng

Ngày: 2026-11-04. Phạm vi: `lib/features/**`, `lib/shared/**`, `lib/app/router/`.

## Tóm tắt

Nguyên nhân gốc của lỗi "bấm Đăng nhập đúng nhưng vẫn ở màn đăng nhập, ô nhập bị xoá":
`refreshListenable` của router chạy lại khi session đổi, nhưng go_router xử lý lại route
**đã push** ở chế độ `restore` và trả về nguyên match list cũ (còn `/login`), nên redirect
không bao giờ được gọi lại cho `/login`. Ngay sau refresh đó `GoRouter.canPop()` trả về
`false`, vì vậy `pop()`/`pushReplacement()` trong màn đăng nhập không rời được màn hình.

Sửa: nút Đăng nhập tự điều hướng bằng `router.go(returnTo ?? home)` với router lấy **trước**
`await` (màn hình có thể bị dispose trong lúc chờ), đồng thời thêm `loginGuard` để người đã
đăng nhập không bao giờ dừng ở `/login`.

## Lỗi tìm thấy và cách sửa

| ID | File:line | Hiện tượng | Nguyên nhân | Cách sửa | Test |
|---|---|---|---|---|---|
| BUG-01 | `lib/features/auth/ui/login_screen.dart:98-110` | Đăng nhập đúng: ô nhập bị xoá, vẫn ở form, quay lại thì đã đăng nhập | Session đổi -> `refreshListenable` -> `GoRouter.refresh()` parse lại `RouteInformation`. Với route push, state được report là `restore` + URI không gồm phần imperative (`/profile`); `RouteConfiguration` `findMatch('/profile')` không có `/login` nên `loginGuard` không chạy, còn `_updateRouteMatchList` kiểu `restore` trả lại đúng `baseRouteMatchList` (có `/login`). Sau đó `canPop()` = false nên `pop()` trong callback không có tác dụng. Code cũ còn dùng `context` sau `await` | Lấy `GoRouter.of(context)` trước `await`; thành công thì `router.go(returnTo ?? AppRoutes.home)` để thay cả stack một cách xác định | `test/app/router_flow_test.dart` - "signing in from the profile card returns to the profile" và "the login form is empty on a later visit" |
| BUG-02 | `lib/app/router/auth_guard.dart:15-24`, `lib/app/router/app_router.dart:73-78` | Người đã đăng nhập vẫn mở được `/login` (deep link, hoặc lúc hydrate xong) | `/login` không có redirect | Thêm `loginGuard`: đã hydrate + đã đăng nhập -> `returnTo` an toàn, nếu không thì `/` | `router_flow_test` - "unsafe returnTo is ignored after sign-in" (đã có) vẫn xanh |
| BUG-03 | `lib/shared/audio/play_gate.dart:20-41`, `lib/features/profile/ui/profile_guest_card.dart:41-45` | Khách bấm Phát / Đăng nhập ngay, đăng nhập xong bị đẩy về tab Khám phá thay vì chỗ vừa đứng | `push(AppRoutes.login)` không có `returnTo`; trước đây dựa vào `pop()` (nay không còn an toàn) | Push `AppRoutes.loginFor(<location hiện tại>)` để `loginGuard`/nút đăng nhập quay lại đúng màn hình | `router_flow_test` (BUG-01) + `play_gate_test` |
| BUG-04 | `lib/features/auth/ui/auth_fields.dart:26-28, 40-42, 65-69` | Đổi Đăng nhập <-> Đăng ký: ô email bị xoá trắng dù model vẫn giữ email; mật khẩu cũ vẫn hiển thị (trước khi key) khi model đã xoá | `TextField` không có key, danh sách con của `Column` đổi (thêm/bớt ô tên) nên element bị dùng lại theo vị trí; ô mật khẩu khoá theo mode nên bị tạo lại | Gắn key ổn định cho từng ô; ô mật khẩu key theo `mode` để khớp với việc model xoá mật khẩu | `test/features/auth/login_form_test.dart` (2 test) |
| BUG-05 | `lib/features/auth/ui/auth_form_view_model.dart:66-74` | Đang gửi đăng nhập mà bấm "Đăng ký" thì mode/password đổi giữa request, lỗi trả về hiện trên mode khác | `setMode` không chặn khi `submitting` | Bỏ qua `setMode` khi đang gửi | — (không có test trực tiếp: cần request treo để dựng lại) |
| BUG-06 | `lib/features/auth/ui/auth_form_view_model.dart:104-107` | Rời màn đăng nhập (nút X) khi request đang chạy -> ghi state lên notifier đã dispose (crash) | Không kiểm tra vòng đời sau `await` | `if (!ref.mounted) return false;` sau `await` | — (test gián tiếp khó ổn định) |
| BUG-07 | `lib/features/auth/ui/session_controller.dart:22-24, 74-87` | Bấm Đăng xuất nhiều lần gửi nhiều request, không có phản hồi | `signOut` fire-and-forget, không chặn trùng | Lần gọi thứ hai dùng chung future đang chạy | `test/features/auth/auth_flow_test.dart` - "a second sign-out joins the request already running" |
| BUG-08 | `lib/features/quiz/ui/quiz_view_model.dart:27-33` | Bấm "Bắt đầu" hai lần liên tiếp: pause audio lần 2, session bị tạo lại (index về 0) | `start()` không kiểm tra stage | Chỉ cho `start()` khi còn ở `introduction` | `test/features/quiz/quiz_flow_test.dart` - "a double tap on Start starts once" |
| BUG-09 | `lib/features/quiz/ui/quiz_view_model.dart:95-98, 121-123` | Thoát quiz khi đang nộp: kết quả trả về muộn ghi đè session đã abandon (hiện màn kết quả trên màn đang rời); "Làm lại" bấm đúp tạo 2 session | `_submit` chỉ kiểm tra `state.value != null`; `retake()` không kiểm tra stage | Chỉ áp kết quả khi stage vẫn là `question`; `retake()` chỉ khi đang `summary` | `quiz_flow_test` - "abandoning during submit ignores the late result" |
| BUG-10 | `lib/shared/audio/play_gate.dart:20-28` | Ở màn player, bấm thẻ "Tiếp theo" sẽ push thêm một `/player` nữa; nút đóng chỉ lùi về player cũ | `playFromUi` luôn `push(AppRoutes.player)` | Bỏ qua push khi `matchedLocation` đã là `/player` | `test/features/player/play_gate_test.dart` (2 test) |

## Đã rà nhưng không sửa (và lý do)

- `lib/features/quiz/ui/quiz_screen.dart:63-79` - nút X gọi `leave()`; bấm đúp rất nhanh có thể mở hai hộp thoại xác nhận. Cần cờ "đang thoát" trong State của màn; tác động thấp và không làm sai dữ liệu, nên ghi nhận.
- `lib/features/quiz/ui/quiz_screen.dart:56` - `PopScope(canPop: false)` khi đang làm bài / đang xem lại là chủ ý (chặn back cứng, buộc xác nhận / quay về kết quả).
- `lib/features/podcast/ui/podcast_screen.dart:21-24` - `RefreshIndicator.onRefresh` chỉ `invalidate` rồi trả về ngay, nên vòng xoay kéo-để-làm-mới tắt trước khi dữ liệu về. Dữ liệu vẫn được tải lại và mỗi khối có loading/error riêng; đây là lỗi hiển thị nhỏ, sửa sẽ phải `await` future và nuốt lỗi (trái quy ước "không nuốt lỗi"), nên giữ nguyên.
- `lib/features/profile/ui/profile_screen.dart:49` - Đăng xuất không có trạng thái bận/hộp thoại xác nhận. Đã chặn request trùng ở controller (BUG-07); phản hồi thị giác là quyết định sản phẩm.
- Điều hướng chỉ bằng tap (thẻ series, tab, mini-player, thẻ quiz...) không debounce: tap đúp có thể push cùng màn hai lần. Chỉ sửa trường hợp player tự push chính nó (BUG-10); sửa toàn bộ cần một cơ chế chặn điều hướng dùng chung, ngoài phạm vi lỗi này.
- `lib/shared/audio/play_gate.dart:26-35` - khách tap Phát hai lần rất nhanh có thể mở hai `LoginRequiredDialog`; `playEpisode` trả `needsLogin` ngay nên rất khó tái hiện. Cần cờ "đang hỏi đăng nhập" ở controller.
- `lib/shared/audio/playback_controller.dart:196-210` - hẹn giờ ngủ vẫn chạy tiếp nếu tập kết thúc trước; khi hết giờ nó chỉ pause (đã pause) rồi tắt cờ. Không sai trạng thái, chỉ thừa một timer ngắn.
- `AuthFormViewModel.submit` không huỷ request khi rời màn (chưa nối `CancelToken`); kết quả muộn bị bỏ qua nhờ BUG-06.
- Các ViewModel `autoDispose` (search, schedule, quiz list, home/timeline filter) reset khi rời màn: đúng ý đồ. Home/Timeline/Quiz list nằm trong `StatefulShellRoute.indexedStack` nên vẫn giữ lựa chọn khi đổi tab.

## Kiểm chứng

- `dart format lib test`: sạch.
- `flutter analyze`: `No issues found!`.
- `flutter test`: 164 passed, 2 skipped (hai test của P11 vẫn skip: BUG-01 audio sync và BUG-02 forgot-password).
- Ba lệnh grep trong `AGENTS.md` mục Verify: không in gì (grep `Color(0x` chỉ khớp `app_design.dart` / `*_colors.dart`; grep `Text('...')` không khớp; không file `lib/` nào > 250 dòng).
- Ghi chú của P11 ("sau lần đăng nhập đúng đầu tiên, màn đăng nhập hiện lại với form rỗng") chính là BUG-01; nay đã tái hiện được bằng test và đã sửa.
