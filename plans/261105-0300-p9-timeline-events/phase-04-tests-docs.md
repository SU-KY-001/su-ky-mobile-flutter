---
status: completed
---

# Phase 4 - Tài liệu

## Không có test
Quy ước của dự án: P1–P10 không viết test, test gom vào P11 (11.1c: parser sự kiện, view model/screen timeline, màn chi tiết). Phase này từng có 4 file test; đã bỏ.

## Tài liệu
- Mới `docs/adr/0011-timeline-and-historical-events.md`: dữ liệu ở `shared/catalog`, dùng `timeLabel` của server, không phân trang (giới hạn 50, 9 sự kiện thật), `PeriodPills` dùng chung, lệch RN về series liên quan, bỏ 9.0a/9.0b, không ảnh bìa.
- `docs/reports/brainstorm-flutter-parity-with-rn.md`: mục P9 đã làm (code xong, chưa kiểm runtime), bảng hiện trạng dòng Catalog (events) và kiểm kê mock; mục 9 (bước tiếp).
- `status: completed` ở `plan.md` và các phase khi đạt tiêu chí 1-3.

## Xong khi
`dart format lib` sạch, `flutter analyze lib` sạch, 3 lệnh Verify rỗng, `flutter build apk --debug` thành công.
