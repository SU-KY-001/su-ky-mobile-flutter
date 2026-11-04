# P11 - Ảnh smoke trên emulator

Máy: `emulator-5554` (Pixel 7, Android 17), app debug chạy bằng `flutter run --dart-define-from-file=env/dev.json`, API thật. Ảnh chụp bằng `adb screencap` (đúng điểm ảnh Android). Chỉ ghi "tôi thấy gì"; bạn là người kết luận đúng/sai.

Tài khoản `user` dùng cho các ảnh đã đăng nhập (email hiện trong ảnh hồ sơ; không có mật khẩu/token). Ảnh khuyết số (12-20, 24-26, 43+) là ảnh gỡ lỗi thao tác nhập liệu, đã xoá.

| Ảnh | Bước | Kỳ vọng | Tôi thấy | Nghi ngờ |
|---|---|---|---|---|
| 01 | Mở app lần đầu (khách) | Khám phá có dữ liệu, 5 tab | Thấy đủ 5 tab, pills thời kỳ, "Đại tác Sử Ký"; nút "Nhiệm vụ tuần" hiện cho khách | không (nút nhiệm vụ cho khách dẫn tới lời mời đăng nhập; bạn xem có muốn ẩn không) |
| 02 | Tab Lịch sử (timeline) | Pills thời kỳ + danh sách sự kiện | 9 sự kiện, nhãn "500 TCN – 111 TCN"; thẻ chưa có ảnh bìa (khối hồng + icon) | không |
| 03 | Tab Podcast | Nổi bật + series + tập mới | Thấy | không |
| 04 | Tab Quiz, ngay sau khi mở | Danh sách quiz | Ảnh bìa trống (đang tải) | không (xem 06) |
| 05 | Tab Cá nhân, khách | Lời mời đăng nhập | Thấy | không |
| 06 | Tab Quiz sau vài giây | Ảnh bìa hiện | Hiện đủ | không |
| 07 | Chi tiết series | Mô tả, danh sách tập, nút quiz | Thấy; có dòng "Bộ dữ liệu demo landing; audio dùng tệp MP3 mẫu." trong mô tả (dữ liệu từ server) | không |
| 08 | Khách bấm Phát | Hộp thoại cần đăng nhập | Thấy, có "Để sau" / "Đăng nhập" | không |
| 09 | Màn đăng nhập | Form rỗng | Ô email/mật khẩu hiện chữ mờ gợi ý (`nguyen.van.a@gmail.com`, `••••••••`); đây là placeholder, không phải giá trị | không |
| 21 | Sai mật khẩu (dùng chuỗi sai) | Báo lỗi, không đăng xuất | "Sai email hoặc mật khẩu" | không |
| 27 | Sau khi đăng nhập đúng | Hồ sơ có tên, XP, lịch sử | Thấy: 0 XP, danh sách "Đã nghe gần đây" 3 mục | không |
| 28 | Thẻ XP -> Nhiệm vụ tuần | Màn nhiệm vụ | Trạng thái rỗng "Chưa có nhiệm vụ tuần này" (tài khoản không có nhiệm vụ) | không |
| 29 | Chuông -> Lịch phát sóng | Tháng 11/2026 | Rỗng "Chưa có lịch phát trong tháng này" (API rỗng) | không |
| 30 | Bấm "Khởi nghĩa Lam Sơn" ở lịch sử | Phát | Player mở, 0:00, hỏi quyền thông báo | không |
| 31 | Sau 8 giây | Tiến độ chạy | 0:18/0:36, hộp thoại quyền thông báo còn hiện | không |
| 32 | Cho phép thông báo | Phát tiếp | 0:29, hộp thoại đã tắt | không |
| 33 | Hết tập | Dừng ở cuối | 0:36, nút Phát | không |
| 34 | Thu nhỏ player | Mini-player + hồ sơ cập nhật | Hồ sơ **20 XP**, "Đã nghe 97%"; mini-player hiện. Server xác nhận `isCompleted`, 97,3% | không |
| 35 | Tab Quiz đã đăng nhập | Danh sách | Thấy | không |
| 36 | Mở quiz "Pháp nổ súng xâm lược" | Màn giới thiệu | 5 câu, điểm đạt 80% (khớp API) | không |
| 37 | Bắt đầu quiz | Câu 1/5, nút tiếp theo bị khoá | Thấy | không |
| 38 | Bấm X giữa bài | Hộp thoại xác nhận thoát | Thấy | không |
| 39 | Bật chế độ máy bay, tab Lịch sử | Dữ liệu cũ vẫn hiển thị | Danh sách còn (cache bộ nhớ) | không |
| 40 | Đổi sang thời kỳ khác khi offline | Lỗi + Thử lại | "Không kết nối được máy chủ." + Thử lại | không |
| 41 | Tắt máy bay, Thử lại | Tải được | Hiện 1 sự kiện của Thời kỳ Bắc thuộc | không |
| 42 | Đăng xuất | Về khách, mini-player mất | Thấy | không |

## Chưa làm được trên emulator
- Hot restart giữ phiên; kéo thông báo xuống kiểm điều khiển phát; tắt/bật màn hình khi đang phát; đóng app mở lại kiểm resume; nộp quiz và xem kết quả/giải thích (quiz đã nộp một lần ở bước API, nên không nộp lại); tab Podcast mục "Tập mới phát hành" cuộn xuống; tìm kiếm có từ khoá.
- Lần đăng nhập đúng đầu tiên: sau khi submit, màn đăng nhập hiện lại (form rỗng) dù hồ sơ báo đã đăng nhập. Chỉ thấy một lần, thử lại 2 lần không dựng lại được (nhập liệu qua bàn phím ảo không ổn định), ảnh gốc đã xoá. **Chưa xác nhận**, ghi ở report.
