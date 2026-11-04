---
status: pending
---

# Phase 6 - Script gọi API thật (11.3)

## Files
- Script tạm `tool/p11_live_api.mjs` (hoặc `eval` JS, không để lại trong repo); **xoá sau khi chạy**, chỉ giữ kết quả trong report.

## Nguyên tắc
- Đọc `API_BASE_URL` từ `env/dev.json`; tài khoản role `user` đầu tiên trong `env/accounts.local.json`. Không in email/mật khẩu/token ra log hoặc report (che bằng `***`). Không dùng tài khoản admin/moderator. Không `sign-up`.
- Mỗi lệnh có timeout; ghi `status` + hình dạng body (khoá + kiểu), không ghi dữ liệu cá nhân.

## Kịch bản
**Chỉ đọc (chạy tự do):**
1. `POST /api/auth/sign-in/email` đúng -> 200 + header `set-auth-token`; sai mật khẩu -> 4xx, không có token.
2. `GET /api/me` với Bearer -> 200; không token -> 401.
3. `GET` series list/detail, episode detail, topics, periods, search `q`, latest episodes, `historical-events`, `historical-periods`, `showcase/releases`.
4. `GET /api/me/listening-history`, `/api/me/weekly-missions`, `/api/quizzes`, `/api/episodes/{slug}/quiz`, `/api/narrations/{id}/playback`.
5. So khớp hình dạng với parser Flutter: mỗi endpoint đối chiếu khoá bắt buộc của parser (đọc parser, không đoán). Khác nhau -> `BUG-nn`.
6. `sign-out` rồi `GET /api/me` với token cũ -> 401.

**Có ghi dữ liệu (đã xác nhận được phép ghi vào tài khoản user test, mỗi loại tối đa một lần):**
7. `PUT /api/me/listening-progress/{narrationId}`: gửi một bitmap nhỏ (vài giây) với `positionMs` hợp lệ; kiểm 200 và `completion` null; thử `assetId` sai để thấy 409 `AUDIO_CHANGED`; bitmap quá dài (>4096 ký tự) để thấy 422. Sau đó `GET listening-history` thấy mục mới.
8. Nộp quiz một lần với `Idempotency-Key` UUID v4; nộp lại **cùng key + cùng nội dung** -> cùng kết quả (không cộng XP lần hai); cùng key khác nội dung -> 422.
Nếu một bước ghi có nguy cơ làm đổi dữ liệu không hoàn tác được (ví dụ quiz đã `hasCompleted`), **dừng và ghi trong report**, hỏi bạn.

## Xong khi
Mục "Kết quả API thật" của report có bảng `endpoint | kỳ vọng | thực tế | khớp parser?`; script đã xoá.
