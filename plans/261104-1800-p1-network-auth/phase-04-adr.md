# Phase 4 — ADR auth/session (task 1.7)

Context: [plan.md](./plan.md). Cần phase 1–3 xong để ghi đúng quyết định đã code.

## Implementation steps
1. Tạo `docs/adr/0003-auth-session.md` (hiện có `0001-architecture.md`, `0002-reference-ui.md`; theo dạng ngắn của 0002: tiêu đề `# 0003 — ...` rồi các đoạn văn).
2. Nội dung phải nêu: token lưu `flutter_secure_storage`, không SharedPreferences; token đọc từ header `set-auth-token`, dự phòng `body.token`; 401 mang Bearer ⇒ xoá phiên qua stream `TokenStore.onCleared`, riêng sign-in/sign-up không xoá; hydrate dùng user cache, chỉ 401 mới đăng xuất, lỗi mạng giữ phiên; mật khẩu 8–128 theo schema API; hai dạng lỗi API (`error_code` và `code`); credential thử nằm ngoài `--dart-define`.

## Todo
- [x] `docs/adr/0003-auth-session.md`

## Success criteria
ADR khớp code đã viết ở phase 1–3; không chứa email/mật khẩu/token thật.
