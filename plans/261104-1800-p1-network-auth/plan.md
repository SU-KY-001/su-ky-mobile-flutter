---
title: "P1 — Mạng + Auth (đăng nhập/đăng ký/đăng xuất thật)"
description: "Thay đăng nhập mock bằng sign-in/sign-up/sign-out thật qua API, phiên bền qua restart, 401 tự xoá phiên."
status: completed
priority: P1
effort: 3d
branch: dev
tags: [feature, frontend, backend, api, auth]
blockedBy: []
blocks: []
created: 2026-11-04
---

> `completed` = code written and `flutter analyze` clean only. Runtime checks (session survives restart, 401 sign-out, secure storage on Android 17) and tests are deferred to P11 and are not verified.

# P1 — Mạng + Auth

## Overview
Thay đăng nhập mock (regex rồi `go(home)`) bằng đăng nhập / đăng ký / đăng xuất thật qua `https://suky-api.the1struleoffightclub.top/` (đã có trong `env/dev.json`). Mốc: đăng nhập và đăng ký thật, phiên bền qua restart app, 401 tự xoá phiên. Giữ UX của RN (`su-ky-project/apps/mobile`): một màn, chuyển qua lại Đăng nhập/Đăng ký. Nguồn: `docs/reports/brainstorm-flutter-parity-with-rn.md` mục P1 (tasks 1.0–1.7).

Chế độ: fast (không research; hợp đồng API đã xác minh bằng gọi thật ở P0).

## Quy ước thực thi (bắt buộc)
- Đọc `AGENTS.md` (root), `lib/core/AGENTS.md`, `lib/features/AGENTS.md` trước khi code.
- **Không viết test, không chạy emulator trong P1.** Toàn bộ test và smoke emulator gom ở P11 của báo cáo. Không đụng thư mục `test/`; test cũ vỡ (`test/widget_test.dart`, `test/core/network/dio_factory_test.dart`, `test/features/auth/login_view_model_test.dart`) để P11 sửa.
- Không thêm dependency mới. Tuân thủ "Enforced standards" của `AGENTS.md` (không chuỗi/màu cứng, state bất biến, file <= 250 dòng, màn không nhận callback điều hướng).
- Xong khi `flutter gen-l10n`, `dart format lib`, `flutter analyze` sạch và các lệnh grep/find ở "Verify" của `AGENTS.md` rỗng.
- Credential thử chỉ ở `env/accounts.local.json` (gitignored). Không chép email/mật khẩu vào plan, code, docs. Không gọi `sign-up` trên API thật.

## Hợp đồng API đã xác minh (2026-11-04, gọi thật bằng tài khoản role `user`)
- `POST /api/auth/sign-in/email` `{email,password}` → 200; header `set-auth-token: <token>`; body `{redirect:false, token, user:{id,name,email,emailVerified,image,role,...}}`. Token có ở **cả header và body**: đọc header trước, dự phòng `body.token`.
- Sai mật khẩu → 401 `{"message":"Invalid email or password","code":"INVALID_EMAIL_OR_PASSWORD"}`. Email đã tồn tại (sign-up) → `{"message":"User already exists. Use another email.","code":"USER_ALREADY_EXISTS_USE_ANOTHER_EMAIL"}` (HTTP status chưa ghi; chỉ dựa vào `code`).
- Lỗi có hai dạng: `/api/auth/*` → `{message, code}`; endpoint khác → `{error_code, message, details?}`. Parser nhận cả hai.
- `GET /api/me` + `Authorization: Bearer <token>` → 200 `{user:{id,name,email,emailVerified,image,role}, session:{expiresAt}}`; token sai/thiếu → 401 `{"error_code":"AUTH_REQUIRED","message":"Authentication required"}`.
- `POST /api/auth/sign-out` + Bearer, body `{}` → 200 `{"success":true}`; token đó sau đó 401 ở `/api/me`.
- Schema (`su-ky-project/packages/shared/src/schemas/auth.ts`): mật khẩu 8–128 ký tự, tên 2–100, email hợp lệ. Flutter đang `minPasswordLength = 6` → sửa 8.
- Retryable (đã chốt): `RATE_LIMITED`, `IDEMPOTENCY_REQUEST_IN_PROGRESS`, `MEDIA_PROVIDER_UNAVAILABLE`, mọi 5xx và lỗi mạng; mọi 4xx khác không.

## Phases
| Phase | Name | Status |
|-------|------|--------|
| 1 | [Lỗi API + TokenStore + Interceptor](./phase-01-core-errors-token-interceptor.md) | Done |
| 2 | [AuthRepository + SessionController](./phase-02-auth-repository-session.md) | Done |
| 3 | [Form Đăng nhập/Đăng ký + l10n](./phase-03-auth-form-ui.md) | Done |
| 4 | [ADR auth/session](./phase-04-adr.md) | Done |

Thứ tự bắt buộc 1 → 2 → 3 → 4 (mỗi phase dựa vào symbol của phase trước). Cây build và `flutter analyze` sạch sau mỗi phase.

## Cross-Plan Dependencies
Không có plan chưa xong nào khác trong `./plans/`. P2 (shell, guard, hồ sơ) chờ P1: dùng `sessionControllerProvider` và `SessionState.isAuthenticated`; nút Đăng xuất làm ở P2.4.

## Assumptions
- `signOut` chưa có nút trên UI trong P1 (ở hồ sơ, P2.4). Nếu muốn có ngay: thêm vào màn login khi đã đăng nhập (ngoài milestone RN, chưa làm).
- `flutter test` có thể đỏ sau P1; chấp nhận cho tới P11.
