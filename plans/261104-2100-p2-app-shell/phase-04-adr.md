# Phase 4 - ADR điều hướng

Context: [plan.md](./plan.md). Cần phase 1-3 xong và đúng như đã code. Theo `AGENTS.md`, đổi kiến trúc thì có ADR; xem `docs/adr/0003-auth-session.md` để theo cùng khuôn.

## Requirements
Tạo `docs/adr/0004-app-shell-navigation.md` ghi lại đúng những gì đã code, ngắn gọn:
- `StatefulShellRoute.indexedStack`, bản đồ `AppTab -> GoRoute` là nguồn sự thật cho nhánh và thanh tab; plan sau thêm một dòng cho tab của mình.
- Route chi tiết ở cấp gốc (ẩn tab và mini-player, đúng RN `hideTabs`); Hồ sơ/Schedule giữ tab bar.
- Mini-player ở shell, hiện theo `AudioState.loaded` (tạm, thay ở P4.5).
- Guard chỉ cho quiz; khách ở Hồ sơ thấy thẻ đăng nhập (đúng RN); `returnTo` kiểm tra bởi `safeReturnTo`; hydrate chưa xong thì không redirect.
- Hậu quả: test cũ dựng router phẳng phải viết lại (P11.1d).

Cập nhật `README.md` nếu có mô tả luồng điều hướng cũ (grep `MainNavigation`, `tab` trước khi sửa; không có thì bỏ qua).

## Todo
- [ ] `docs/adr/0004-app-shell-navigation.md`

## Success criteria
ADR khớp code phase 1-3; không chứa email, mật khẩu, token.
