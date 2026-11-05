# Báo Cáo Chuyển Giao: Đổi UX Mobile Toàn Bộ App Sang Pattern Chuẩn

- **Dự án:** `su_ky_mobile_flutter` (Flutter, Riverpod 3, go_router, Android).
- **Mục tiêu:** Bỏ thiết kế tự chế (các button quá to, mini player nổi lơ lửng, layout rườm rà). Chuyển sang sao chép 1:1 layout từ các app lớn đã chứng minh UX tốt (Spotify, Apple Podcasts, Duolingo, Wikipedia...).
- **Tài liệu đặc tả chuẩn:** `docs/reports/ux-reference-spec.md` (đã viết chi tiết cấu trúc từng màn hình).

---

## 1. Bản Đồ Tham Chiếu UX Cho Từng Màn Hình

| Màn hình | App tham chiếu | Layout & Component chính |
|---|---|---|
| **Home (Khám phá)** | **Spotify Home** | Title "Sử Ký" (20/w800) + icon Search & Trophy góc phải. Hàng chips thời kỳ (cao 32). Hàng "Tiếp tục nghe" compact (ảnh 56 + tiêu đề + thanh progress mỏng bên dưới). Teaser Nhiệm vụ tuần mỏng (Duolingo quests row). Shelf ngang các series (cover vuông 150) + danh sách "Tập mới phát hành" dạng row phẳng. |
| **Search** | **Spotify Search** | `AppBar` tích hợp input tự động focus, không đóng khung card, nút xoá (X), danh sách kết quả dạng row 72px phẳng. |
| **Podcast Tab** | **Apple Podcasts / Spotify** | Hero 16:9 cho series nổi bật, shelf ngang series vuông 150, danh sách tập mới dạng row có ảnh 56 và nút Play tròn bên phải. |
| **Chi tiết Series** | **Spotify / Apple Show** | Cover vuông 200 ở giữa, meta 1 dòng, nút Play tròn 56 bên phải, mô tả giới hạn 3 dòng + "Xem thêm", danh sách tập: tên, mô tả mờ, nút OutlinedButton "Quiz" nhỏ và nút Play tròn 48. Đã bỏ chữ "Moderator". |
| **Full Player** | **Spotify Podcast Player** | Chevron xuống + "Đang phát từ" + menu ⋮ (Làm quiz / Về series). Cover vuông lớn, thanh seekbar mỏng kèm timestamp 2 đầu. Hàng điều khiển: Speed, -15s, nút Play/Pause tròn 72 (chuyển icon Replay khi hết bài), +15s, Sleep timer. Segmented control chọn giọng đọc (khi >1 giọng). Khối bo góc dưới cùng chứa 2 row: Làm quiz và Tập tiếp theo. |
| **Mini Player** | **Spotify / YT Music** | Docked ngay trên Bottom Navigation Bar (không nổi lơ lửng, không bo viền). Cao 56px, ảnh 40px, title 1 dòng, subtitle 1 dòng, nút Play/Pause 48x48, đường kẻ tiến độ mỏng 2px dưới cùng. |
| **Quiz (List & Play)** | **Duolingo Lesson** | **List:** Khối chia divider, thumbnail 64, tích xanh cho bài đã xong.<br>**Play:** Nút Close (X) + thanh tiến độ dày bo tròn (10px accent) ở top bar; câu hỏi chữ to (24/w700); các ô lựa chọn full-width (cao 56+, viền 2px, đổi màu viền + tint khi chọn); nút "Tiếp tục" / "Nộp bài" dính cố định dưới đáy màn hình.<br>**Result:** Điểm số to ("4/5"), nút "Tiếp tục" chính + "Xem lại đáp án". |
| **Nhiệm Vụ Tuần** | **Duolingo Quests** | Summary card (tổng XP, ngày còn lại, thanh tiến độ tổng). Các hàng nhiệm vụ phẳng phân cách bằng divider: icon 48, tên, thanh tiến độ dày kèm "2/5", badge nhận XP. Bỏ avatar thừa ở header. |
| **Hồ Sơ (Profile)** | **Spotify / Duolingo** | Header phẳng (không bọc card): Avatar 72 + Tên + Email. Hàng thống kê phẳng (XP, nhiệm vụ xong). Các row điều hướng tới Nhiệm vụ, Lịch phát sóng. Danh sách "Đã nghe gần đây" dạng row phẳng. Nút "Đăng xuất" dạng row text đỏ kèm dialog xác nhận. Trạng thái khách: nút Đăng nhập + link Đăng ký. |
| **Timeline (Lịch sử)** | **Apple Calendar / Wikipedia** | App bar tiêu đề gọn, thanh timeline bên trái giữ nguyên, bỏ toàn bộ các khối màu hồng giả ảnh (`event_color_block`). Row sự kiện gọn (minHeight 96). |
| **Schedule (Lịch phát)** | **Apple Podcasts Upcoming** | Gom nhóm theo ngày phát (header "Thứ Sáu, 6 tháng 11"), các row có ảnh 56, trạng thái chuông hoặc play. |
| **Đăng nhập (Auth)** | **Spotify Auth** | Màn phẳng: title, input có label rõ ràng, 1 nút Submit lớn, chuyển mode đăng nhập/đăng ký qua text link dưới cùng. Bỏ các card viền và nút demo Google. |

---

## 2. Trạng Thái Hiện Tại Của Codebase

- **Đã làm xong toàn bộ code:**
  - Tất cả các màn hình ở `lib/features/**/ui/` đã được viết lại xong theo spec.
  - Các widget dùng chung (`lib/shared/widgets/`) đã cập nhật (docked `MiniPlayer`, `ShelfCard`, `SeriesShelf`, `AppDesign` tokens...).
  - Thiết kế token trong `lib/shared/design/app_design.dart`: `pagePadding = 16`, `radius = 12`, `coverRadius = 8`, `tapTarget = 48`.
  - Theme trong `lib/app/theme/app_theme.dart`: `navigationBarTheme.height = 64`, `appBar.centerTitle = false`, `appBar.titleTextStyle.fontSize = 20`.
- **Kiểm thử tự động:**
  - `flutter analyze`: **0 lỗi** (clean hoàn toàn).
  - `flutter test`: **185/185 tests PASS** (toàn bộ test unit, viewmodel, widget).
  - Không vi phạm các quy tắc AGENTS (không hardcode màu, không hardcode chuỗi, tất cả chuỗi qua ARB vi/en, file <= 250 dòng).

---

## 3. Ảnh Thực Tế Đã Kiểm Tra Trên Emulator (Pixel 7)

Tất cả ảnh chụp đã lưu trong `docs/reports/ux-audit/`:
1. `docs/reports/ux-audit/10-home.png` & `24-home-mini.png`: Màn Home mới + Mini-player docked.
2. `docs/reports/ux-audit/11-timeline.png`: Màn Timeline gọn gàng, bỏ khối hồng.
3. `docs/reports/ux-audit/12-podcast.png`: Màn Podcast tab hero 16:9 + shelf ngang + rows.
4. `docs/reports/ux-audit/13b-quizlist.png`: Màn danh sách Quiz phẳng, avatar 64 + tích xanh.
5. `docs/reports/ux-audit/14-profile.png`: Màn Profile phẳng, stats + gần đây + đăng xuất.
6. `docs/reports/ux-audit/15-quizintro.png` & `16-quizq1.png` & `17-quizexit.png`: Luồng Quiz Duolingo (intro, câu hỏi chọn tile, dialog thoát).
7. `docs/reports/ux-audit/19-player.png`: Full Player kiểu Spotify Podcast.
8. `docs/reports/ux-audit/22-series-chip.png`: Màn chi tiết Series (bản cũ, còn nút Quiz chip dạng OutlinedButton).
9. `docs/reports/ux-audit/23-missions.png`: Màn Nhiệm vụ tuần.

### 3.1. Đợt verify lại sau khi gỡ chip Quiz (build debug mới, 2026-11-04)

Các ảnh `30`–`33` được chụp lại từ APK debug build mới nhất (`flutter build apk --debug` + `adb install -r`) trên Pixel 7:

1. `docs/reports/ux-audit/30-home-rebuild.png`: Màn Home — **không còn gạch vàng-đen overflow 1px** ở shelf, số tập ("1 tập", "2 tập", "5 tập") hiện đủ.
2. `docs/reports/ux-audit/31-series-rebuild.png`: Màn chi tiết Series — cover 200, meta 1 dòng, nút Play tròn, mô tả 3 dòng + "Xem thêm".
3. `docs/reports/ux-audit/32-series-episodes.png`: Danh sách tập — chỉ còn title, mô tả mờ, meta ngày·thời lượng và nút Play tròn; **không còn chip Quiz** trên từng dòng.
4. `docs/reports/ux-audit/33-quiz-list-rebuild.png`: Tab Quiz — vẫn là điểm vào quiz thay thế (row phẳng, chip chủ đề, tích xanh bài đã xong).

---

## 4. Điểm Cần Chú Ý & Xử Lý Tiếp (Kế Thừa)

> Trạng thái cập nhật 2026-11-04: mục 1 và 2 đã xử lý xong; mục 3 (commit) còn chờ quyết định.

1. **~~Vấn đề overflow 1.00 pixel ở ShelfCard trên màn Home~~ — ĐÃ XỬ LÝ:**
   - Nguyên nhân gốc nằm ở `lib/shared/widgets/series_shelf.dart`: chiều cao shelf cố định không đủ cho 2 dòng tiêu đề + 1 dòng số tập khi text scale lớn.
   - Cách sửa: chiều cao shelf giờ scale theo `MediaQuery.textScalerOf(context).scale(_shelfTextHeight)`, nên mọi mức text scale đều vừa.
   - Đã thêm regression test `test/shared/widgets/series_shelf_test.dart` (text scale 1.0 / 1.15 / 1.3 / 1.5 / 2.0, dùng `AppTheme.light`, assert không có exception layout).
   - Đã xác nhận bằng ảnh `30-home-rebuild.png`: gạch overflow biến mất.
2. **~~Vấn đề N+1 request và nút Quiz ở Series~~ — ĐÃ XỬ LÝ:**
   - **Nguyên nhân:** Payload `GET /api/series/{slug}` không có trường `hasQuiz` cho từng episode con. Lúc trước `EpisodeQuizChip` được gắn vào mỗi dòng tập ở `episode_list_tile.dart` và gọi `ref.watch(episodeDetailProvider(slug))`. Điều này gây ra lỗi **N+1 request** (nếu series có 20 tập thì bắn 20 request tải chi tiết tập chỉ để xem có quiz hay không), vi phạm trực tiếp quy chuẩn `CLAUDE.md`.
   - **Giải pháp đã áp dụng:**
     - Bỏ nút chip Quiz trên từng row ở màn chi tiết Series (`episode_list_tile.dart`), đúng chuẩn layout Spotify/Apple Podcasts (chỉ hiển thị title, mô tả tóm tắt, ngày, thời lượng, nút Play).
     - Người dùng vẫn làm quiz bình thường qua 2 nơi hợp lý hơn: Tab Quiz riêng (`/quizzes` - xác nhận ở `33-quiz-list-rebuild.png`) hoặc ngay trong màn Player (khi bấm nghe tập, Player đã tải sẵn `EpisodeDetail` và có nút "Làm quiz" ở menu ⋮ và khối Up-next cuối màn).
     - Đã xóa `lib/features/series/ui/episode_quiz_chip.dart` và key `episodeQuizChip` trong `lib/l10n/app_vi.arb` + `lib/l10n/app_en.arb`.
     - Đã chạy `flutter gen-l10n`.
     - Đã thay test case cũ trong `test/features/series/series_screen_test.dart` bằng regression test chống N+1: `episode rows do not fetch episode detail to resolve quizzes` — đếm số lần gọi `episodeDetail` trên repo fake và assert bằng 0, đồng thời assert mỗi dòng tập có đúng 1 nút Play.
3. **Các file chưa commit:**
   - Toàn bộ các thay đổi đang nằm ở working tree (`git status` có các file modified/deleted/untracked).
   - Có thể chạy lệnh commit theo quy chuẩn của repo sau khi test thêm:
     ```sh
     flutter analyze
     flutter test
     git add .
     git commit -m "feat(ui): redesign screens according to proven mobile app patterns"
     ```
4. **Quy trình chạy kiểm tra:**
   - `flutter gen-l10n`
   - `dart format --set-exit-if-changed lib test`
   - `flutter analyze`
   - `flutter test`

---

## 5. Đợt sửa UX nhóm Hồ sơ (2026-11-04)

**Vấn đề:** profile nằm ngay trên bottom navigation (không app lớn nào làm vậy), và màn hồ sơ để 4 mục (nhiệm vụ, lịch phát sóng, lịch sử nghe, đăng xuất) cùng một cấp nên rất phẳng, khó phân biệt.

**Đã đổi:**

1. **Bottom nav 5 → 4 tab** (`lib/shared/widgets/main_navigation.dart`): bỏ `AppTab.profile`. Các tab còn lại: Khám phá, Lịch sử, Podcast, Quiz.
2. **`/profile` thành route đẩy riêng** (`lib/app/router/app_router.dart`): nằm ngoài `StatefulShellRoute` nên mở full màn, có back arrow, không có bottom bar và mini-player.
3. **Avatar góc trên phải màn Home** (`lib/features/home/ui/home_avatar_button.dart`): khách thấy icon `person_outline`, người đã đăng nhập thấy chữ cái đầu trên nền tint. Bấm → `context.push(AppRoutes.profile)`.
4. **Thiết kế lại `ProfileScreen` theo hierarchy của YouTube "You":**
   - Header danh tính (avatar 72 + tên 22/w800 + email) — không bọc card.
   - Khối tổng quan trên nền `AppDesign.tint` (radius 12): XP và số nhiệm vụ xong, có vạch chia dọc.
   - Nhãn section "Hoạt động" + một group viền mảnh chứa 2 row 56px: Nhiệm vụ tuần (kèm XP bên phải) và Lịch phát sóng. Row = icon 40 trong vòng tròn tint + tiêu đề 15/w600 + giá trị muted + chevron.
   - Nhãn section "Đã nghe gần đây" + danh sách row phẳng kiểu Spotify (không card).
   - Nhãn section "Tài khoản" + group riêng chỉ có row "Đăng xuất" màu error, không chevron, vẫn có dialog xác nhận.

**File mới:** `profile_group.dart` (`ProfileSectionLabel` + `ProfileGroup`), `profile_nav_row.dart` (`ProfileNavRow`), `home_avatar_button.dart`.
**File sửa:** `main_navigation.dart`, `app_router.dart`, `home_header.dart`, `profile_screen.dart`, `profile_stats.dart`, `profile_missions_row.dart`, `profile_schedule_row.dart`, `profile_sign_out_row.dart`, `profile_history_section.dart` (bỏ tiêu đề tự thân, nhãn do screen cấp), `app_vi.arb` / `app_en.arb` (thêm `profileSectionActivity`, `profileSectionAccount`; sửa `missionsHeaderTitle` thành sentence case).

**Test:** `router_flow_test` giờ assert đúng 4 `NavigationDestination`, profile không nằm trong `NavigationBar`, và avatar mở `/profile` không còn bottom bar. `profile_screen_test` thêm case "rows are grouped under section labels" (2 `ProfileGroup`, đăng xuất nằm group riêng). Tổng: **187/187 pass**, `flutter analyze` sạch.

**Ảnh verify trên Pixel 7:** `40-home-avatar.png` (4 tab + avatar), `41-profile-youtube.png` (header + stats + group Hoạt động + lịch sử), `42-profile-bottom.png` (hết danh sách + group Tài khoản).
