# Phase 2 - Màn nhiệm vụ tuần nối API (task 7.1b)

## Files
Sửa/viết lại trong `lib/features/weekly_missions/ui/`: `weekly_missions_screen.dart`, `weekly_missions_header.dart`, `mission_widgets.dart`, `mission_l10n.dart`, và `weekly_missions_view_model.dart` (nếu chỉ còn quản lý mock thì xoá, dùng thẳng `weeklyMissionsProvider`; **không** giữ view model chỉ để forward).
Đọc từng file trước khi sửa (scout không đọc hết nội dung từng widget).

## Nội dung màn
- Đầu màn: tổng XP (`totalXp`) và số nhiệm vụ đã xong (`completedCount`); hạn tuần "Hết hạn {ngày}" từ `weekEnd` (ICU date, theo múi giờ máy).
- Danh sách `items`: icon theo `activity` (UI map: `completeEpisode`→headphones, `passQuiz`→award, như RN), `title` từ API, thanh tiến độ, `progressCount/targetCount`, `+{xpReward} XP`, chip trạng thái (Hoàn thành / Hết hạn khi `status != inProgress`). Item `completed` hiển thị dấu hoàn thành, `expired` mờ.
- Trạng thái: loading, lỗi (thông báo từ `AppException` + nút thử lại), rỗng ("Chưa có nhiệm vụ tuần này"), khách (màn chỉ vào được khi đăng nhập; nếu route đã guard ở P2 thì không cần nhánh khách, kiểm `app_router.dart`).
- Không còn: nút huy hiệu Vinh danh, lịch điểm danh, streak, thẻ chi tiết.
- Key ARB mới thêm cả `app_vi.arb` và `app_en.arb`; xoá key mồ côi ở phase 3.
- Nút "Nghe tiếp"/mở tab Podcast ở màn (P4 để tạm) giữ nguyên hành vi hiện tại, không mở rộng.

## Xong khi
`flutter analyze` sạch; không còn import `data/mock_missions.dart` trong màn; mỗi file <= 250 dòng, mỗi widget công khai một file.
