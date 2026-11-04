---
status: completed
---

# Phase 4 - Test + tài liệu

## Test mới (tự biên dịch, chạy riêng được; không sửa test cũ vỡ, việc đó ở P11)
- `test/shared/history/history_repository_test.dart`: payload hợp lệ (percent thập phân → làm tròn/clamp, >100 → 100); item hỏng bị bỏ qua nhưng item tốt giữ lại; thiếu `items` → lỗi; 401 → `Err`; rỗng → danh sách rỗng.
- `test/features/schedule/schedule_repository_test.dart`: `from`/`to` đúng đầu tháng và < 62 ngày (kể cả tháng 31 ngày, qua năm tháng 12→1); item hỏng bỏ qua; rỗng.
- `test/features/schedule/schedule_view_model_test.dart`: `previous`/`next` qua ranh giới năm.
- `test/features/profile/profile_screen_test.dart` (fake repo + fake session): khách không gọi history; user thấy lịch sử + XP; trống; lỗi + thử lại; tập `!available` không có nút nghe. Điều hướng assert bằng `router.routerDelegate.currentConfiguration.last.matchedLocation` (chuông → `/schedule`, thẻ XP → `/weekly-missions`).
- `test/features/schedule/schedule_screen_test.dart`: trống, danh sách (nhãn đúng, nút nghe chỉ khi `released`), đổi tháng gọi lại repo với tháng mới.

## Tài liệu
- `docs/adr/0010-profile-history-schedule.md`: lịch sử trong Hồ sơ (không tab), history ở `shared` vì làm mới theo `learningActivityProvider`, lệch RN có chủ ý (thẻ XP dẫn sang màn nhiệm vụ thay vì liệt kê), tháng tính giờ địa phương, bỏ lọc/phân trang theo parity RN.
- `docs/reports/brainstorm-flutter-parity-with-rn.md`: sửa P8 (bỏ 8.0a/b/c; bỏ "lọc trạng thái, phân trang"), bảng kiểm kê mock (dòng Hồ sơ/Lịch sử nghe/Lịch phát hành), mục 5 và mục 9 "Đã LÀM" kèm "chưa kiểm runtime".
- `status: completed` ở `plan.md` và phase sau khi: `dart format lib test`, `flutter analyze` sạch trong `lib/`, 3 lệnh Verify rỗng, test mới pass, `flutter build apk --debug` thành công.
