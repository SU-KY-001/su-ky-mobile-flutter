---
status: completed
---

# Phase 2 - l10n: tên app và metadata

## Files
- `lib/l10n/app_vi.arb`: đổi "Sử Kế" thành "Sử Ký" ở `appName`, `brandAudio` ("SỬ KÝ AUDIO"), `seriesHeading`, `noAccount` (grep `Sử Kế` rỗng sau khi sửa).
- `lib/l10n/app_en.arb`: "Su Ke" thành "Su Ky" ở `appName`, `brandAudio`, `noAccount`, `authSignUpHeading`.
- `lib/l10n/app_en.arb`: thêm 5 khối `@metadata` thiếu, sao đúng placeholder/type từ `app_vi.arb`: `@episodeMinutes`, `@missionsProgressRatio`, `@missionsWeekEnd`, `@missionsXpReward`, `@seriesEpisodeCount`.
- `lib/core/config/app_config.dart:22`: `AppConfig.appName` hiện không được dùng cho UI (UI dùng `AppLocalizations.appName`); grep consumer, nếu 0 thì xoá hằng để không còn hai nguồn tên.

## Lưu ý
- Chỉ đổi giá trị, không đổi tên key. Nếu bạn chọn giữ "Sử Kế" ở quyết định 2, phase này chỉ làm phần metadata và `playerSeriesLine` cho khớp.
- Ký tự `·`, `•`, `-` trong `Text('...${}')` do scout nêu là dấu phân cách, không phải chữ; không đổi.

## Xong khi
`flutter gen-l10n` chạy được, `flutter analyze lib` sạch, 3 lệnh Verify rỗng, hai ARB cùng bộ khoá và metadata.
