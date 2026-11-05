---
status: completed
---

# Phase 1 - Gỡ Drift và package không dùng

## Files
- Xoá `lib/core/storage/app_database.dart` (và `.g.dart` nếu còn trên đĩa; file sinh bị ignore).
- Sửa `lib/core/di/providers.dart`: bỏ `databaseProvider` (dòng ~42-46) và import tương ứng.
- Sửa `pubspec.yaml`: bỏ `drift`, `drift_flutter`, `drift_dev`, `freezed_annotation`, `freezed`, `json_annotation`, `json_serializable`, `path`; bỏ `build_runner` nếu không còn codegen (`grep "part '.*\.g\.dart'"` rỗng).
- Chạy `flutter pub get` để cập nhật `pubspec.lock`.

## Việc
1. Trước khi xoá: `grep -rn "databaseProvider\|AppDatabase" lib test` để chắc chắn 0 consumer ngoài hai file trên (test cũ cũng không dùng).
2. Xoá, sửa, `flutter pub get`.
3. Nếu thư mục `lib/core/storage/` chỉ còn `token_store.dart`: giữ nguyên (không đổi tên).

## Xong khi
`flutter pub get` thành công, `dart format lib` sạch, `flutter analyze lib` sạch, 3 lệnh Verify rỗng, `flutter build apk --debug` thành công.
