# Phase 4 - Tài liệu

- Thêm `docs/adr/0007-listening-progress-sync.md`: bitmap LSB base64 thuần Dart, không nạp lại bitmap server, tua không đánh dấu giây, 409/422/429 xử lý ra sao, `ProgressSync` tách khỏi controller vì giới hạn 250 dòng, `learningActivityProvider` ở `core` với consumer đầu tiên là P7.
- `docs/reports/brainstorm-flutter-parity-with-rn.md`: dòng Player (sync bitmap đã nối), mục P5 chuyển "ĐÃ LÀM (code xong, chưa kiểm runtime)", mục 9 "Bước tiếp".
- Đặt `status: completed` cho `plan.md` và các phase sau khi `dart format lib`, `flutter analyze`, 3 lệnh Verify đều sạch.
