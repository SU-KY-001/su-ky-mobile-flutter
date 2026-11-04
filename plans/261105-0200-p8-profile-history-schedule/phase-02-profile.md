---
status: completed
---

# Phase 2 - Hồ sơ đầy đủ (tasks 8.1, 8.2b)

## Files (`lib/features/profile/ui/`)
- `profile_screen.dart` (hiện 40 dòng): thêm chuông ở header → `context.push(AppRoutes.schedule)` (hằng số thêm ở phase 3; làm phase 3.1 trước hoặc cùng lúc). Khách: giữ `ProfileGuestCard`, **không** hiện XP/history. Đã đăng nhập: `ProfileUserCard` → `ProfileXpCard` → `ProfileHistorySection`. Còn ≤ 250 dòng.
- `profile_xp_card.dart` (mới): đọc `weeklyMissionsProvider` (`shared/missions`). Hiện `totalXp` và `completedCount` (ICU plural trong ARB). Bấm → `context.push(AppRoutes.weeklyMissions)`. Loading: skeleton đơn giản; lỗi hoặc `null`: ẩn thẻ (thẻ phụ, không chặn hồ sơ) nhưng **đã log** ở repo.
- `profile_history_section.dart` (mới): tiêu đề "Đã nghe gần đây" + `CatalogAsyncView<ListeningHistory?>` (`shared/widgets/catalog_states.dart`): loading, lỗi + thử lại (`ref.invalidate(listeningHistoryProvider)`), trống ("Chưa có lịch sử nghe", ARB).
- `history_tile.dart` (mới, một widget công khai): tên tập, `{series} · Đã nghe {percent}%` (ICU placeholder, không nối chuỗi), thanh tiến độ giá trị `percent / 100`, nút nghe tiếp nếu `available`. Bấm dòng hoặc nút = `playFromUi(context, ref, entry.episodeSlug, narrationId: entry.narrationId)` (`shared/audio/play_gate.dart`). Tập `!available`: không nút, dòng mờ.

## ARB (vi VÀ en, `flutter gen-l10n`)
Kiểm `app_en.arb` trước, tái dùng `profileTitle`, `continueListening`. Thêm: `profileXpTotal`, `profileMissionsDone` (plural), `profileRecentTitle`, `profileRecentEmpty`, `profileHistoryProgress` (`series`, `percent`), `profileScheduleTooltip`. Màu/kích thước: token `AppDesign` hoặc `const` đặt tên; không `Color(0x…)`.

## Không làm
Không liệt kê danh sách nhiệm vụ trong Hồ sơ (quyết định 2). Không lọc/phân trang (quyết định 3). Không import `features/weekly_missions` hay `features/auth/ui` nội bộ sai luật: `sessionControllerProvider` đã được profile dùng sẵn, giữ nguyên.

## Xong khi
`flutter analyze` sạch trong `lib/`, mọi file ≤ 250 dòng, 3 lệnh Verify của `AGENTS.md` rỗng.
