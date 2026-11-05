# Phase 6 - ADR audio + README + report + trạng thái plan (task 4.9)

Context: [plan.md](./plan.md). Cần phase 1-5 xong và đúng như đã code. Theo khuôn `docs/adr/0003-auth-session.md`, `0004`, `0005` (ghi đúng những gì đã code, không viết điều chưa làm).

## Requirements
- `docs/adr/0006-audio-playback.md` (số kế tiếp sau `0005`): chọn `just_audio` + `just_audio_background` (không `AudioHandler`), phiên bản thực lấy từ `pubspec.lock`, một `AudioPlayer` + một controller không `autoDispose`, `playEpisode(slug)` là đường vào duy nhất, cổng khách (`pendingPlay`, TTL), quyền thông báo bằng `MethodChannel` thay vì `permission_handler`, bỏ yêu thích, hẹn giờ ngủ dùng `Timer`, vị trí cục bộ `pos.<narrationId>`, khác RN (phát nền, giữ vị trí khi đổi ngôi kể). Ghi rõ **chưa kiểm**: seek/Range trên URL Cloudinary, ngôi kể thứ hai trên dữ liệu thật, hẹn giờ khi Doze, Android 17.
- `README.md`: dòng mô tả Player đã nghe thật; bỏ câu "Player is still a mock" và đoạn nói chưa có audio; thêm quyền thông báo và dịch vụ foreground vào phần Android; cách thử (đăng nhập tài khoản trong `env/accounts.local.json`, xem README mục env).
- `docs/reports/brainstorm-flutter-parity-with-rn.md`: Status (P4 xong mức code); bảng hiện trạng (Player/Mini-player thật); mục P4 chuyển sang bảng có cột Trạng thái như P1-P3; ghi các lệch (nút quiz Player ẩn tới P6, Missions "Nghe tiếp" mở Podcast, bỏ yêu thích, `flutter build apk` đã chạy ở phase 1); mục "Bước tiếp" trỏ P5.
- `plans/261104-2300-p4-audio-core/plan.md`: `status: completed`, bảng phase `Done`, tick mọi todo trong các phase.

## Todo
- [x] ADR 0006
- [x] README
- [x] Report
- [x] Status plan + todo
