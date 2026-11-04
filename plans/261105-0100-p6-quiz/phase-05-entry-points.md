---
status: completed
---

# Phase 5 - Điểm vào quiz từ Player và Series

RN có 4 điểm vào (tab Quiz, banner tập hiện tại ở Podcast, Series "Làm quiz tập này", Player "Làm quiz"). Tab đã làm ở phase 2. Phase này thêm **Player và Series**; **bỏ banner Podcast** (không có tương đương Flutter hiện tại; thêm khi có nhu cầu).

## Files
- `lib/features/player/ui/`: nút "Làm quiz" ở màn Player (chỗ báo cáo P4 đã ẩn tới P6), chỉ hiện khi `episode.hasQuiz` (`EpisodeDetail.hasQuiz`, đã parse). Bấm → `context.push(AppRoutes.quizFor(slug))`. `authGuard` lo khách.
- `lib/features/series/ui/`: nút "Làm quiz tập này" trên dòng tập có `hasQuiz` (kiểm tra model tập ở series detail có `hasQuiz` chưa; nếu chưa có thì dùng `episodeDetailProvider` hoặc bỏ nút ở Series và ghi lý do vào report, không thêm trường API không xác minh).
- ARB vi/en: `playerStartQuiz`, `seriesStartEpisodeQuiz`.
- Không import ruột feature khác: chỉ dùng `AppRoutes` và `shared/catalog`.

## Xong khi
Từ Player và Series bấm nút mở đúng `/episodes/{slug}/quiz`; `flutter analyze` sạch; file ≤ 250 dòng.
