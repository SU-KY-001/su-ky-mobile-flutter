---
status: pending
---

# Phase 5 - Widget test luồng chính + dọn test cũ (11.1d, 11.2)

## Files
- `test/widget_test.dart`: sửa lỗi `slug` ở dòng 93 hoặc tách thành test mới đúng chủ đề; xoá khẳng định chỉ ghim chữ.
- Mới `test/app/` (hoặc `test/features/...`):
  - Đăng nhập/đăng ký: sai -> hiện lỗi, đúng -> về `returnTo`; không bấm đúp gửi hai lần.
  - Shell: 5 tab chuyển đúng route; mini-player giữ khi đổi tab; Back ở tab gốc.
  - `authGuard` + `returnTo`: khách vào `/episodes/:slug/quiz` -> `/login?returnTo=...`, đăng nhập xong quay lại đúng nơi; `returnTo` ngoài app bị bỏ (deep link không tin cậy); trước khi hydrate xong không chuyển hướng nhầm.
  - Play khi là khách: hiện hộp thoại yêu cầu đăng nhập; huỷ thì xoá yêu cầu; đăng nhập xong trong TTL thì phát.
- Rà toàn bộ `test/`: mọi file còn lỗi compile/analyze hoặc chỉ ghim chữ -> sửa hoặc xoá và ghi vào report (mục "Test cũ").

## Kiểm (11.2)
```sh
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
# phải rỗng:
grep -rnE "Color\(0x" lib --include=*.dart | grep -vE "app.theme|shared.design|_colors\.dart|l10n.gen"
grep -rnE "Text\((const )?['\"][^'\"$]*[A-Za-zÀ-ỹ]" lib --include=*.dart | grep -v "l10n.gen"
find lib -name '*.dart' -not -path '*/l10n/gen/*' -not -name '*.g.dart' | xargs wc -l | awk '$1>250 && $2!="total"'
```
Nếu một lệnh `lib/` không rỗng thì **ghi vào report như BUG**, không sửa `lib/`.

## Xong khi
Ba lệnh đầu xanh (analyze 0 lỗi gồm `test/`); `git diff --stat -- lib pubspec.yaml` rỗng.
