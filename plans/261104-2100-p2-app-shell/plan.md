---
title: "P2 - Khung ứng dụng (shell: 5 tab + mini-player + guard)"
description: "StatefulShellRoute dùng chung, thanh tab chỉ hiện tab đã có màn, mini-player trong shell, auth guard + returnTo, tab Hồ sơ tối thiểu."
status: completed
priority: P1
effort: 2d
branch: dev
tags: [feature, frontend, navigation]
blockedBy: []
blocks: [261104-2130-p3-catalog]
created: 2026-11-04
---

# P2 - Khung ứng dụng (shell)

Nguồn: `docs/reports/brainstorm-flutter-parity-with-rn.md` mục P2 (tasks 2.0–2.4) + 4 scout (code Flutter, RN `apps/mobile`).
**Không viết test, không chạy emulator ở P2** (quy ước report mục 5: gom vào P11). Mốc đạt = `dart format`, `flutter analyze` sạch trong `lib/`, 3 lệnh grep/find ở "Verify" của `AGENTS.md` rỗng.

## Hiện trạng (đã xác minh bằng scout)
- Router phẳng 9 route, `AppRouter.create()` giữ trong `_AppState` (`lib/app/app.dart`), không `redirect`.
- `MainNavigation` (3 mục) + `MiniPlayer` định nghĩa trong `lib/shared/widgets/su_ke_widgets.dart` (220 dòng). Home và Missions nhúng tab riêng, Search nhúng cả `MiniPlayer`. Mini-player luôn hiện, lấy `audioViewModelProvider` (mock, không có khái niệm "đã nạp tập").
- 7 chỗ `context.push(AppRoutes.login)` đang đóng vai "vào Hồ sơ" (không có màn Hồ sơ).
- `SessionState{hydrated, user}`, `isAuthenticated` ở `lib/features/auth/ui/session_controller.dart`.

## Hành vi RN cần giữ (từ `HeritageApp.tsx`)
- 5 tab: Khám phá, Lịch sử, Podcast, Quiz, Hồ sơ. Màn chi tiết `event/series/player/episodeQuiz/login` **ẩn tab bar và mini-player**; `profile/schedule` giữ tab bar.
- Mini-player chỉ hiện khi đã nạp một tập; nút tua −15s + play/pause; chạm vào mở Player.
- Khách: duyệt được mọi thứ, **không nghe**, **không làm quiz**. Tab Hồ sơ của khách **không redirect**: hiện thẻ "Chưa đăng nhập" + nút "Đăng nhập ngay". Đăng nhập thành công quay lại đúng màn trước đó. Back/huỷ ở login bỏ `pendingPlay`.
- Đăng xuất: không có hộp thoại xác nhận.
- Không có splash chặn lúc hydrate: UI render ngay như khách, `/api/me` 401 thì lặng lẽ về khách.

## Quyết định (lệch so với report, cần bạn biết)
1. **Tab Hồ sơ của khách không bị redirect sang login** (report 2.3 ghi "khách bấm profile thì sang login"). Theo RN: thẻ khách + nút đăng nhập. Guard redirect chỉ áp cho route quiz.
2. **Không khai báo route `event` và `schedule`** ở P2 (report 2.2): chưa có màn, route không màn = placeholder. `/events/:slug` thêm ở P9.2, schedule ở P8.3 (con của nhánh Hồ sơ để giữ tab bar).
3. **Route series giữ nguyên** (`/series/bach-dang-938`): đổi sang `/series/:slug` thuộc P3.4. Route quiz giữ tham số `int` tới P6.4.
4. **Search không còn là tab** (RN không có tab Search). Thành route gốc `/search`, mở từ Home. Missions/Honours/MissionDetail cũng là route gốc (không tab bar), đóng bằng nút back sẵn có.
5. **Thanh tab chỉ hiện tab đã đăng ký nhánh** (P2: Khám phá, Hồ sơ). P3 thêm Podcast, P6 thêm Quiz, P9 thêm Lịch sử: mỗi plan thêm một dòng vào bản đồ `AppTab -> route`.
6. `MiniPlayer` hiện khi `AudioState.loaded` (trường mới, mặc định false, set true ở `playEpisode`/`toggle`). P4.5 thay bằng `PlaybackController`.
7. Đổi tên không cần: giữ `MainNavigation`, đổi chữ ký (danh sách tab + callback chọn) và chuyển sang file riêng.

## Phase
| Phase | Tên | Trạng thái |
|-------|-----|-----------|
| 1 | [Tab Hồ sơ tối thiểu + l10n](./phase-01-profile-tab.md) | Done |
| 2 | [Shell: AppTab, StatefulShellRoute, mini-player, gỡ nhúng cũ](./phase-02-shell-router.md) | Done |
| 3 | [Auth guard + returnTo](./phase-03-auth-guard-return-to.md) | Done |
| 4 | [ADR điều hướng](./phase-04-adr.md) | Done |

Thứ tự bắt buộc 1 → 2 → 3 → 4. Cây build và `flutter analyze` sạch sau mỗi phase.

## Test cũ sẽ vỡ (không sửa ở P2, ghi để P11.1d xử lý)
- `test/widget_test.dart:51-95`: chạm `Tìm kiếm`/`Cá nhân` trên Home, dựng màn riêng lẻ không có shell.
- `test/features/weekly_missions/ui/weekly_missions_screen_test.dart:12-21,53,61-69`: `_router()` phẳng, `find.byType(MainNavigation)`, chạm nhãn tab.
- `mission_detail_screen_test.dart` và `quiz_screen_test.dart` tự dựng `GoRouter` nên ít khả năng vỡ; kiểm ở P11.

## Rủi ro
- `StatefulShellRoute` lồng `Scaffold` (shell + `AppPage`): kiểm inset đáy và `maxWidth` ở P11.4. `AppPage` hiện đặt `bottom` full width, shell giữ y hệt.
- Route gốc đặt cùng cấp `StatefulShellRoute` phải phủ lên shell khi `push` (hành vi go_router mặc định). Xác nhận bằng smoke ở P11.4.
- Hydrate chưa xong thì guard không redirect (tránh đẩy nhầm người đã đăng nhập sang login); xong hydrate guard chạy lại nhờ `refreshListenable`.
- Không có test: lỗi điều hướng chỉ lộ ở P11.

## Ngoài phạm vi
Tab Lịch sử/Podcast/Quiz, route event/schedule, `pendingPlay` và cổng khách khi bấm Play (P4.7), lý do đăng nhập tuỳ biến (RN có `loginReason`), hộp thoại xác nhận đăng xuất (RN không có), hồ sơ đầy đủ (P8.0a).
