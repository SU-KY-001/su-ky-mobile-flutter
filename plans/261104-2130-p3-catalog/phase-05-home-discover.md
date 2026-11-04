# Phase 5 - Khám phá (Home) theo thời kỳ (task 3.6)

Context: [plan.md](./plan.md). Cần phase 1-4. Hiện `HomeViewModel extends Notifier<int>` (chip all/battles/people, `homeCategoryCount = 3`), series/tập mới là mock theo `MockCatalog.thumbnails`.

## Requirements
Nguồn UX: RN `DiscoveryScreen.tsx:34-150` (pills thời kỳ lấy từ `/api/historical-periods`).
- `HomeViewModel` → `Notifier<String?>` (id thời kỳ đang chọn, `null` = Tất cả), `autoDispose`, `select(String? id)`; bỏ `homeCategoryCount` và 3 key chip mock (`all`, `battles`, `people` nếu không còn dùng chỗ khác).
- `home_screen.dart`:
  - Pills: "Tất cả" + `periodsProvider` (cuộn ngang; RN chỉ lấy 3 đầu, mình hiện tất cả vì cuộn ngang được; nếu dữ liệu thật quá nhiều thì cắt bằng hằng đặt tên).
  - Khối series: `seriesListProvider(selectedPeriodId)` → `SeriesCard` → `seriesFor(slug)`.
  - Khối "Tập mới": `latestEpisodesProvider` với `LatestEpisodeTile` (đã có ở phase 3).
  - **Giữ nguyên** `ContinueListeningCard` (vẫn dùng audio mock; P4.8/5.4 thay) và nút Nhiệm vụ tuần.
  - Mỗi khối có loading/lỗi/rỗng qua `catalog_states.dart`.
- Xoá `new_episode_tile.dart` (mock), cùng mọi tham chiếu `MockCatalog.thumbnails`.
- Tách file nếu `home_screen.dart` > 250 dòng (hiện 177).
- ARB: `homeAllPeriods`, `homeSeriesEmpty`; xoá key mock không còn tham chiếu (grep xác nhận).

## Related files
Sửa: `features/home/ui/{home_screen,home_view_model,home_header?}.dart`; xoá `new_episode_tile.dart`; ARB; `mock_catalog.dart` (xoá `thumbnails` nếu hết consumer).

## Todo
- [ ] `HomeViewModel` theo `periodId`
- [ ] Pills + khối series + khối tập mới thật
- [ ] Xoá `NewEpisodeTile` + dọn mock/ARB

## Success criteria
`flutter gen-l10n`, `dart format lib`, `flutter analyze` sạch; `grep -rn "MockCatalog.thumbnails" lib` rỗng; 3 lệnh "Verify" rỗng.

## Risks
- Đổi thời kỳ → `seriesListProvider` family mới, giữ cache riêng từng thời kỳ trong 60s (chấp nhận).
- Dữ liệu seed có thể không có series cho một thời kỳ: UI rỗng phải đẹp (`homeSeriesEmpty`).
