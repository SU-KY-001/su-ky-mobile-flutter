---
title: "P11 - Kiểm thử một lượt, ghi lỗi vào report, không sửa"
description: "Viết/sửa test, chạy gọi API thật bằng tài khoản user, chạy app trên emulator. Lỗi của app chỉ ghi vào docs/reports/p11-test-findings.md; không sửa lib/."
status: pending
priority: P1
effort: 2d
branch: dev
tags: [test, qa]
blockedBy: []
blocks: []
created: 2026-11-05
---

# P11 - Kiểm thử, chỉ ghi lỗi

Nguồn: report mục P11 (11.1a-d, 11.2-11.4), P1-P10 đã `completed` (không còn plan nào chặn). Baseline đo 2026-11-05: `flutter analyze` 147 lỗi, đều trong `test/` (`lib/` sạch); `flutter test` vỡ ở compile: `dio_factory_test` (`ValidationException` đã bỏ), `login_view_model_test` (file `login_view_model.dart` không còn), `home_view_model_test` (`selectCategory`, `homeCategoryCount` không còn), `widget_test.dart:93` thiếu `slug`, cùng các test mission/quiz/audio cũ.

## Luật cứng của plan này
1. **Không sửa `lib/`, `pubspec.yaml`, ARB, router.** Chỉ được tạo/sửa/xoá file trong `test/`, tạo script tạm, tạo report.
2. **App sai thì ghi, không vá.** Mỗi lỗi một mục `BUG-nn` trong `docs/reports/p11-test-findings.md` (mẫu ở phase 1). Test tương ứng giữ nguyên khẳng định đúng và đánh `skip: 'BUG-nn, xem report'` để suite vẫn xanh nhưng lỗi không bị giấu.
3. **Test cũ vỡ vì code đổi** (không phải lỗi app): viết lại theo hành vi hiện tại hoặc xoá nếu chỉ ghim chữ/layout (AGENTS.md). Mỗi test xoá/viết lại ghi một dòng vào mục "Test cũ" của report.
4. **Dữ liệu thật:** script API và smoke emulator chỉ dùng tài khoản role `user` (`env/accounts.local.json`), không `sign-up`, không ghi ngoài tiến độ nghe và nộp quiz của chính tài khoản đó (phase 6 và 7, mỗi loại tối thiểu cần thiết). Không in/chụp mật khẩu hay token.
5. Mỗi test có khẳng định có nghĩa (happy path, rỗng, lỗi, biên). Không test dây nối, không test chữ.
6. Không chạy `flutter test` cả suite lẻ tẻ: mỗi phase chỉ chạy file của phase đó; cả suite chạy ở phase 5.

## Phase

| # | Phase | Kết quả | Trạng thái |
|---|---|---|---|
| 1 | [Baseline + khung report](phase-01-baseline-report.md) | Danh sách test vỡ, report khung | pending |
| 2 | [Test hạ tầng + Auth](phase-02-core-auth.md) | 11.1a | pending |
| 3 | [Test Catalog + Player + Progress](phase-03-catalog-player-progress.md) | 11.1b | pending |
| 4 | [Test Quiz, Missions, Hồ sơ, Lịch sử, Lịch phát hành, Timeline](phase-04-features.md) | 11.1c | pending |
| 5 | [Widget test luồng chính + dọn test cũ](phase-05-widget-flows.md) | 11.1d, 11.2 | pending |
| 6 | [Script gọi API thật (user, chỉ đọc + 1 lần nộp có kiểm soát)](phase-06-live-api.md) | 11.3 | pending |
| 7 | [Tôi tự chạy emulator bằng computer use, ảnh vào `docs/reports/p11-screenshots/`, chốt report](phase-07-emulator-final.md) | 11.4 | pending |

Thứ tự: 1 -> {2,3,4} -> 5 -> 6 -> 7. Phase 2-4 độc lập về file nên làm tuần tự cũng được; không có phụ thuộc chéo.

## Rủi ro / không kiểm được
- Android 17 emulator: foreground service, `POST_NOTIFICATIONS`, `FlutterSecureStorage` chưa từng chạy; điều khiển emulator qua computer use có thể không làm được (tắt màn hình, tắt mạng, kéo thông báo). Bước nào không làm được thì ghi "Chưa kiểm được" kèm lý do.
- Dữ liệu thật: lịch phát hành rỗng cả năm, tài khoản user chưa có nhiệm vụ tuần; những màn này chỉ test được bằng repo giả, ghi rõ trong report là "chưa thấy dữ liệu thật".
- Tiến độ nghe và quiz thật ghi lên tài khoản test: quiz chỉ nộp ở một nơi (phase 6 hoặc 7, không cả hai) và chỉ với quiz chưa hoàn thành; ghi lại trong report.

## Tiêu chí xong
- `dart format --set-exit-if-changed lib test`, `flutter analyze` (0 lỗi, kể cả `test/`), `flutter test` xanh (test bị `skip` do BUG vẫn tính xanh nhưng phải liệt kê đủ trong report).
- 3 lệnh grep/find trong "Verify" của `AGENTS.md` rỗng.
- `git diff --stat -- lib pubspec.yaml` rỗng (chứng minh không sửa app).
- `docs/reports/p11-test-findings.md` có: bảng BUG, bảng test cũ đã sửa/xoá, kết quả API thật, mục "Chưa kiểm được", đường dẫn thư mục ảnh.
- `docs/reports/p11-screenshots/` có ảnh từng bước smoke và `README.md` mục lục (ảnh, bước, kỳ vọng, tôi thấy gì, nghi ngờ). Bạn là người kết luận đúng/sai từ ảnh.
- App đang chạy trên `emulator-5554` sau khi xong.
