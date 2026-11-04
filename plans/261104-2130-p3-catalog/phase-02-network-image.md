# Phase 2 - Ảnh mạng + ảnh dự phòng

Context: [plan.md](./plan.md). Cần hằng số của phase 1. Hiện `CoverArt` (`lib/shared/widgets/su_ke_widgets.dart`, ~dòng 200) chỉ `Image.asset(path)` với mặc định `MockCatalog.cover`; `SeriesCard` chọn `cover`/`secondCover` cứng.

## Requirements
- `lib/shared/widgets/cover_art.dart`: `CoverArt({url, fallbackSeed, height, width})`. `url` hợp lệ (`https`) → `Image.network` với `loadingBuilder` (khung màu nền) và `errorBuilder` rơi về ảnh dự phòng; `url == null` → ảnh dự phòng. Không thêm gói ảnh.
- `lib/shared/catalog/fallback_art.dart`: `String fallbackArtFor(String seed)` chọn trong danh sách asset cục bộ hiện có bằng `seed.codeUnits.fold(0, +) % assets.length` (ổn định giữa các lần chạy, không dùng `String.hashCode`). Danh sách asset là hằng trong `shared/mock/mock_catalog.dart` hoặc file `fallback_art.dart` tuỳ chỗ hiện có (`bach_dang.jpg`, `dong_a.jpg`, thumbnails); **không** mở rộng `AppDesign`.
- Xoá `CoverArt` cũ khỏi `su_ke_widgets.dart`; sửa mọi chỗ gọi hiện có (Player: `player_screen.dart:70`, `SeriesCard`, `RelatedEpisodeTile`, `NewEpisodeTile`) sang chữ ký mới để build không vỡ. Người gọi chưa có URL truyền `url: null` + seed.
- `Semantics`/`semanticLabel` lấy từ ARB nếu ảnh có nghĩa; ảnh trang trí thì `excludeFromSemantics`.

## Related files
Tạo: `shared/widgets/cover_art.dart`, `shared/catalog/fallback_art.dart`. Sửa: `su_ke_widgets.dart` (xuống còn nhỏ hơn), `series_card.dart`, `player_screen.dart`, `related_episode_tile.dart`, `new_episode_tile.dart`.

## Todo
- [ ] `fallbackArtFor` (ổn định)
- [ ] `CoverArt` mạng + dự phòng
- [ ] Cập nhật mọi chỗ gọi, xoá `CoverArt` cũ

## Success criteria
`flutter analyze` sạch; `grep -rn "CoverArt(" lib` đều dùng chữ ký mới; 3 lệnh grep/find "Verify" rỗng.

## Risks
- `Image.network` ném lỗi bắt buộc xử lý qua `errorBuilder`; không `print`.
- Chỉ nhận URL `https` (cleartext bị Android chặn mặc định); URL khác coi như `null`.
