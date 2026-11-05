---
status: pending
---

# Phase 7 - Tôi tự chạy app trên emulator bằng computer use, chụp ảnh vào một thư mục, chốt report (11.4)

Bạn xem ảnh để phán đoán đúng/sai; tôi không tự kết luận "đạt" thay bạn. Tôi chỉ ghi "thấy gì" và đánh dấu nghi ngờ.

## Đã thử trước khi viết plan (2026-11-05, Pixel_7, Android 17)
- Ảnh chụp bằng `computer` (cửa sổ hoặc màn hình) **không thấy nội dung app**: vùng màn hình emulator ra xám/đen (GPU không bị chụp), cây AX chỉ có nút thanh công cụ. => Chụp ảnh bằng `adb exec-out screencap -p` (đúng pixel Android, 1080x2400), lưu thẳng vào thư mục ảnh.
- Click nền bằng `computer` **không tới** emulator. `click(x, y, {takeover: true})` thì tới (đã thử: bấm tab Tìm kiếm, app đổi tab). => Thao tác dùng `computer` với `takeover: true`; chụp bằng adb. Takeover cướp chuột của bạn trong lúc chạy; tôi làm theo từng loạt ngắn và báo trước. Toạ độ: ánh xạ từ khung hình adb (1080x2400) sang cửa sổ emulator (vùng màn hình khoảng x 22-401, y 20-878 trong ảnh cửa sổ 423x896; kiểm lại bằng một cú bấm thử mỗi phiên).
- Nhập chữ: ưu tiên `computer` `type` vào cửa sổ (takeover); nếu không ăn thì `adb shell input text`, chỉ cho email, **không** dùng cho mật khẩu để khỏi lọt vào lịch sử lệnh/log (mật khẩu chỉ gõ qua `computer`).
- Emulator đang cài **bản app cũ** (3 tab, dữ liệu giả). Bắt buộc `flutter run` mới (hoặc `flutter install`) trước khi chụp bất cứ thứ gì, rồi chụp một ảnh xác nhận thấy 5 tab.

## Chuẩn bị
1. `flutter emulators --launch Pixel_7`, chờ `flutter devices` có máy Android (`emulator-5554`).
2. Chạy app bằng bash dịch vụ có tên, `ready` theo log: `flutter run -d emulator-5554 --dart-define-from-file=env/dev.json`. Giữ job sống tới cuối phase để bạn mở xem.
3. Lấy cửa sổ emulator: `computer.window({app: ...})` (tìm theo `computer.windows()`; không có thì `computer.apps.open`). Mỗi thao tác chạy trong `computer.run`, xong chụp lại để kiểm chứng; không đoán toạ độ, ưu tiên cây AX nếu emulator lộ ra, không thì dùng ảnh chụp.
4. Tài khoản: đọc `env/accounts.local.json`, **chỉ dùng tài khoản role `user`**. Không dùng admin/moderator, không `sign-up`. Gõ email/mật khẩu bằng `type`, không bao giờ ghi mật khẩu/token vào report, log hay tên file. Trước khi chụp màn đăng nhập đã gõ mật khẩu, kiểm ô mật khẩu đang che; nếu không che thì không chụp màn đó.
5. Thư mục ảnh: `docs/reports/p11-screenshots/`. Tên `NN-<luồng>-<bước>.png` (ví dụ `03-guest-play-dialog.png`), NN tăng dần theo thứ tự chạy. Một file `docs/reports/p11-screenshots/README.md` là mục lục: `ảnh | bước | kỳ vọng | tôi thấy gì | nghi ngờ (có/không)`. Ảnh lưu bằng đường dẫn mà `screenshot` trả về rồi copy sang thư mục này (bash `cp`). Ảnh lỗi thêm hậu tố `-BUG-nn`.

## Kịch bản (mỗi bước: thao tác, chụp, ghi mục lục)
**A. Khách**
1. Mở app lần đầu: Khám phá có dữ liệu, thanh 5 tab.
2. Podcast, Series (chi tiết, danh sách tập), tìm kiếm (từ khoá có kết quả, từ khoá không có, 1 ký tự), Timeline (pills thời kỳ, danh sách, chi tiết sự kiện, trích dẫn, series liên quan).
3. Bấm Play một tập: hộp thoại yêu cầu đăng nhập. Mở tab Quiz, chọn một quiz: chuyển sang đăng nhập.
**B. Đăng nhập**
4. Sai mật khẩu (dùng mật khẩu sai tự bịa, không phải mật khẩu thật): thấy lỗi, không bị đăng xuất vòng lặp.
5. Đúng: vào app, quay lại `returnTo` nếu đến từ Play/Quiz.
6. Hot restart (`r` trên job `flutter run`): còn phiên.
**C. Nghe (ghi tiến độ lên tài khoản test, đúng một tập)**
7. Phát một tập: mini-player xuất hiện, tạm dừng, tua +15s, đổi tốc độ, hẹn giờ ngủ, đổi tab mà mini-player còn.
8. Màn hình Android tắt rồi bật lại (phím nguồn emulator qua giao diện cửa sổ) và kéo thông báo xuống: có điều khiển phát không; cấp quyền thông báo nếu hỏi (ghi nhận lời hỏi). Nếu emulator không điều khiển được thì ghi "không kiểm được", không ép.
9. Tắt hẳn app rồi mở lại: Hồ sơ "Đã nghe gần đây" có tập vừa nghe; mở lại tập: resume đúng vị trí (ghi vị trí trước/sau).
10. Nghe hết tập chỉ khi tập đủ ngắn hoặc tua được tới cuối; nếu không đạt thì ghi "không kiểm được hoàn thành".
**D. Quiz, nhiệm vụ, hồ sơ**
11. Tab Quiz: danh sách, lọc chủ đề, badge đã hoàn thành. Nộp bài **chỉ với một quiz chưa `hasCompleted`** và chỉ nếu phase 6 chưa nộp quiz đó; kết quả + giải thích; Làm lại tạo lần mới. Nếu mọi quiz đã hoàn thành thì bỏ qua và ghi lý do.
12. Hồ sơ: XP, nhiệm vụ đã xong, "Đã nghe gần đây", nút nghe tiếp, bấm thẻ XP -> màn nhiệm vụ tuần (có thể rỗng), chuông -> Lịch phát hành (đổi tháng, tháng rỗng).
13. Đăng xuất: về khách; vào Hồ sơ thấy lời mời đăng nhập.
**E. Mạng**
14. Tắt mạng emulator (qua giao diện cửa sổ extended controls, hoặc chế độ máy bay), mở Khám phá/Timeline/Hồ sơ: thấy lỗi + Thử lại, không treo; bật lại, bấm Thử lại thì tải được.

Bước nào không thực hiện được (điều khiển emulator không có, quyền, dữ liệu) thì không bỏ lặng: ghi vào mục "Chưa kiểm được" kèm lý do.

## Ghi lỗi
Cái gì sai (crash, trắng màn, chữ cắt, dữ liệu sai, bấm không ăn, spinner vô hạn): chụp ảnh `-BUG-nn`, thêm hàng vào bảng Bug của `p11-test-findings.md` (đường dẫn ảnh làm bằng chứng). **Không sửa `lib/`.** Lấy log từ job `flutter run` (stack, lỗi) đưa vào bằng chứng, che token nếu có.

## Chốt
1. Report: bảng bug theo mức, danh sách test `skip` kèm `BUG-nn`, mục "Chưa kiểm được" (Doze, foreground service Android 17, `POST_NOTIFICATIONS`, dữ liệu thật rỗng), đường dẫn thư mục ảnh.
2. Giữ app chạy trên emulator; không đóng job.
3. Cập nhật dòng P11 trong `docs/reports/brainstorm-flutter-parity-with-rn.md` -> "ĐÃ LÀM" trỏ tới `p11-test-findings.md`; `status: completed` cho plan và phase khi tiêu chí đạt.

## Xong khi
- `docs/reports/p11-screenshots/` có ảnh cho mọi bước đã chạy + `README.md` mục lục đầy đủ.
- Bước không chạy được có trong "Chưa kiểm được".
- Không có mật khẩu/token trong ảnh, mục lục, report; `git diff --stat -- lib pubspec.yaml` rỗng.
- App còn chạy trên `emulator-5554`.
