---
status: completed
---

# Phase 6 - Tài liệu

- `docs/adr/0009-quiz-attempt.md`: vì sao bỏ kiểm tra từng câu (API giấu đáp án), `Idempotency-Key` UUID v4 tự sinh không thêm gói, giữ key khi retry/đổi khi Làm lại, bỏ `timeLimit` (parity RN), topic suy ra từ catalog (không `/api/topics`), không phân trang (limit 50), khách đi qua `authGuard`.
- `docs/reports/brainstorm-flutter-parity-with-rn.md`: mục P6 đánh dấu "Đã làm (code xong, chưa kiểm runtime)", cập nhật dòng 3.2/6.1 (không dùng `/api/topics`), dòng kiểm kê mock "Làm quiz" và "Tab Quiz", mục 9 "Bước tiếp"; ghi rõ chưa kiểm POST thật và test quiz cũ vỡ chờ P11.
- `plans/261105-0000-p7-missions-xp/phase-03-refresh-cleanup.md`: ghi P6 đã gọi `bump()` khi `isPassed`.
- `status: completed` ở `plan.md` và các phase sau khi đạt tiêu chí phase 4-5 (`dart format lib`, `flutter analyze` sạch trong `lib/`, 3 lệnh Verify rỗng, `flutter build apk --debug` thành công).
