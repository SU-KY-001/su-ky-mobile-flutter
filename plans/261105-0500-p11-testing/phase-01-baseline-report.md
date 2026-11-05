---
status: pending
---

# Phase 1 - Baseline + khung report

## Files
- Tạo `docs/reports/p11-test-findings.md`.

## Việc
1. Chạy `flutter analyze` và `flutter test` một lần, ghi số lỗi analyze và danh sách file test vỡ compile hoặc fail (mỗi file một dòng, kèm lý do ngắn) vào mục "Baseline".
2. Tạo report với các mục:
   - **Baseline** (ở trên).
   - **Bug của app** - bảng: `ID | Màn/module | Bước tái hiện | Mong đợi | Thực tế | Bằng chứng (test/log/ảnh) | File nghi ngờ | Mức (cao/vừa/thấp) | Trạng thái (open)`.
   - **Test cũ đã sửa/xoá** - `file | hành động | lý do`.
   - **Kết quả API thật** (phase 6).
   - **Kết quả smoke emulator** (phase 7): trỏ tới `docs/reports/p11-screenshots/README.md`.
   - **Chưa kiểm được**.
3. Chưa viết test ở phase này.

## Xong khi
Report tồn tại, mục Baseline có số liệu đo thật từ lệnh vừa chạy. Không file nào ngoài `docs/reports/` thay đổi.
