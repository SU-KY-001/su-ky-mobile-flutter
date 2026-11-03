# Phase 6 - Tìm kiếm thật (task 3.5)

Context: [plan.md](./plan.md). Cần phase 1-5. Hiện `search_view_model.dart`: `SearchState{query, era, recent}` trong `Notifier<AsyncValue<SearchState>>` (`AsyncValue` không bao giờ loading/lỗi → sai quy tắc), lọc bộ nhớ trên chuỗi cứng, không debounce; `search_screen.dart` 202 dòng.

## Requirements
- `SearchState` bất biến: `query`, `status` (`idle|loading|ready|error`), `items` (`List<SeriesSummary>`), `page`, `total`, `loadingMore`, `error` (`AppException?`); `copyWith`; `hasMore`.
- `SearchViewModel extends Notifier<SearchState>` (`autoDispose`): `onChanged(String)` đặt `query` ngay, huỷ `Timer` cũ, hẹn `searchDebounce` (350 ms) rồi gọi `GET /api/series?q=` trang 1 (`seriesPageSize`); `query.trim().length < searchMinChars` (2) → `idle`, không gọi API. Chống kết quả cũ ghi đè bằng token tăng dần; `ref.onDispose` huỷ `Timer`. `loadMore()` nối trang kế khi `hasMore`; `retry()`.
- Màn: `SearchInput` (giữ nút mic: hiện `demoNotice`), `idle` → danh sách gợi ý từ `seriesListProvider(null)` (không "tìm gần đây"); `loading` → `CatalogLoading`; `ready` rỗng → `emptyResults` sẵn có; `error` → `CatalogError` + retry; cuối danh sách có nút "Tải thêm" nếu `hasMore`.
- Search là route gốc (P2): có nút back (P2 phase 2). Không `MiniPlayer`.
- **Xoá** chip thời kỳ, "tìm gần đây", "xoá lịch sử", "tập liên quan": `related_episode_tile.dart` và key ARB mock tương ứng (`allEras`, `southernHan`, `lyTran`, `recentSearches`, `clearHistory`, `featuredSeries`, `resistanceTag`, `searchDescription`, `relatedEpisodes`, `bestMatch`, `resultsCount`... chỉ xoá key đã `grep` xác nhận hết consumer).
- Tách `search_screen.dart`: `search_results_list.dart`, `search_idle_view.dart`; mỗi file < 250 dòng.
- Hằng `searchDebounce`, `searchMinChars` ở `catalog_constants.dart` (phase 1).
- ARB: `searchLoadMore`, `searchMinCharsHint`.

## Related files
Sửa: `features/search/ui/{search_screen,search_view_model}.dart`, ARB, `shared/widgets/search_input.dart` (nếu cần); xoá `related_episode_tile.dart`; tạo 2 file con.

## Todo
- [ ] `SearchState` + `SearchViewModel` (debounce, token chống lệch, loadMore)
- [ ] Màn + 2 file con, gỡ mock UI
- [ ] Dọn ARB/mock không còn consumer

## Success criteria
`flutter gen-l10n`, `dart format lib`, `flutter analyze` sạch; `grep -rn "AsyncValue<SearchState>" lib` rỗng; 3 lệnh "Verify" rỗng; không file > 250 dòng.

## Risks
- Server tìm `ILIKE` trên `title` thôi (không `description`): ghi trong ADR.
- Không có test: logic debounce/token chỉ kiểm ở P11.
