# Kick-off cho thành viên mới

Đọc theo thứ tự. Mục tiêu: sau khoảng 30 phút bạn chạy được app trên emulator Android và chạy xanh bộ kiểm tra. Chi tiết tính năng và kiến trúc nằm ở [README](../README.md); tài liệu này chỉ lo phần setup và quy trình làm việc.

## 1. Cài công cụ

| Công cụ | Phiên bản | Ghi chú |
| --- | --- | --- |
| Flutter | 3.47+ (Dart 3.13+) | Kênh `stable`. `pubspec.yaml` yêu cầu `sdk: ^3.13.2` |
| Android Studio | bản mới | Cài Android SDK, platform-tools, Emulator, tạo AVD |
| JDK | đi kèm Android Studio | Gradle dùng JDK này, không cần cài riêng |
| Git | bất kỳ | |
| VS Code (tùy chọn) | | Có sẵn cấu hình chạy `Su Ky - Android` (F5) |

App **chỉ hỗ trợ Android**. Không cần iOS, web hay desktop.

Kiểm tra môi trường:

```sh
flutter doctor -v
```

Mục `Android toolchain` phải có dấu tích. Nếu thiếu license: `flutter doctor --android-licenses`.

## 2. Lấy code và cài thư viện

```sh
git clone <repo-url>
cd su-ky-mobile-flutter
flutter pub get
```

- `flutter pub get` cài đúng phiên bản đã khóa trong `pubspec.lock` (file này được commit). Không dùng `flutter pub upgrade` trừ khi bạn đang chủ ý nâng thư viện.
- Thêm thư viện mới: `flutter pub add <tên>`, rồi ghi lý do (license, độ phổ biến, kích thước) trong PR. Không thêm thư viện chỉ để dùng một hàm nhỏ.
- Dự án **không dùng codegen** (không `build_runner`). Chỉ l10n được sinh tự động, xem bước 4.

## 3. Cấu hình môi trường

App đọc cấu hình lúc build qua `--dart-define`. Có hai khóa:

| Khóa | Giá trị | Ghi chú |
| --- | --- | --- |
| `ENV` | `dev`, `staging`, `prod` | Mặc định `dev`. Giá trị sai làm app dừng ngay |
| `API_BASE_URL` | URL http(s) tuyệt đối | Bắt buộc. Thiếu hoặc sai thì app dừng trước `runApp` |

Tạo file cấu hình từ mẫu:

```sh
# macOS / Linux / Git Bash
cp env/dev.example.json env/dev.json

# Windows PowerShell
Copy-Item env/dev.example.json env/dev.json
```

Sau đó sửa `API_BASE_URL` trong `env/dev.json` thành URL backend thật (hỏi trưởng nhóm). URL trong file mẫu chỉ là placeholder.

Quy tắc:
- `env/*.json` bị git-ignore. Chỉ file `env/*.example.json` được commit.
- Không đặt secret trong `--dart-define`: giá trị bị nhúng vào APK và có thể trích xuất.
- Tài khoản test đặt trong `env/accounts.local.json` (git-ignored). Mẫu ở `env/accounts.example.json`. Không commit file này và không dán mật khẩu vào chat hay PR.

## 4. Sinh file l10n

Chuỗi hiển thị nằm trong `lib/l10n/app_vi.arb` (template) và `app_en.arb`. Output sinh ra ở `lib/l10n/gen/` và bị git-ignore, nên **phải chạy sau khi clone**:

```sh
flutter gen-l10n
```

Chạy lại mỗi khi sửa file `.arb`. Thiếu bước này, project báo lỗi không tìm thấy `app_localizations.dart`.

## 5. Khởi động emulator và chạy app

```sh
flutter emulators                          # liệt kê AVD
flutter emulators --launch <emulator-id>   # ví dụ: Pixel_7
flutter devices                            # chờ tới khi thấy thiết bị android
flutter run -d <device-id> --dart-define-from-file=env/dev.json
```

Emulator thường có id `emulator-5554`. Lần build đầu mất khoảng 1 phút do Gradle tải phụ thuộc.

Phím trong phiên `flutter run`:

| Phím | Tác dụng |
| --- | --- |
| `r` | Hot reload (giữ trạng thái) |
| `R` | Hot restart (về trạng thái đầu) |
| `q` | Thoát |

Khi nào cần dừng hẳn rồi chạy lại: đổi `env/*.json`, đổi `pubspec.yaml`, đổi file Android native. Hot reload/restart không áp dụng cấu hình build-time.

Dùng VS Code: chọn thiết bị ở thanh trạng thái, chọn cấu hình `Su Ky - Android`, nhấn F5.

Nếu màn hình trắng hoặc app thoát ngay: kiểm tra đã truyền `--dart-define-from-file=env/dev.json` chưa và `API_BASE_URL` có hợp lệ không.

## 6. Lệnh hằng ngày

```sh
dart format lib test                       # định dạng code
flutter analyze                            # phải sạch, không warning
flutter test                               # chạy toàn bộ test
flutter test test/features/timeline        # chạy test một feature
flutter test path/to/file_test.dart --name "tên test"
```

Trước khi mở PR, chạy đúng bộ này, cả ba phải xanh:

```sh
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

Định nghĩa "xong": ba lệnh trên xanh, tài liệu được cập nhật, thay đổi hành vi có test đi kèm, sửa bug có test hồi quy.

Build APK release (phân phối ngoài store):

```sh
flutter build apk --release --dart-define-from-file=env/prod.json
```

## 7. Cấu trúc code và quy ước phải nhớ

```
lib/
  main.dart          khởi tạo: error hooks, config, runApp
  app/               App widget, router, theme
  core/              config, di, error, logging, network, storage, auth
  features/<name>/   ui/ domain/ data/ — một thư mục mỗi feature
  shared/            widget dùng bởi từ 2 feature trở lên
  l10n/              ARB (vi + en)
test/                phản chiếu lib/ một-một
docs/adr/            quyết định kiến trúc
```

Quy ước cứng (đầy đủ trong [AGENTS.md](../AGENTS.md)):

- Phụ thuộc một chiều: `ui -> domain <- data`. `core` không import `features` hay `app`. Feature không import ruột của feature khác.
- Chuỗi hiển thị không viết thẳng trong `.dart`: dùng `context.l10n.<key>`, thêm key vào **cả** `app_vi.arb` và `app_en.arb`.
- Không hardcode URL, timeout, số magic, màu `Color(0x...)` ngoài theme và `AppDesign`. Dùng hằng có tên.
- State màn hình nằm trong `Notifier` của Riverpod với state bất biến. `setState` chỉ dùng cho UI tạm thời (animation, focus, scroll).
- Không nuốt lỗi: trả `Result` hoặc `AppException`, log qua `AppLogger`, không log token hay PII.
- Mọi I/O bất đồng bộ có timeout.
- File `.dart` không quá 250 dòng. Điều hướng dùng hằng trong `app_routes.dart`.
- Không để `TODO`, `FIXME`, `HACK` hay code bị comment.
- Đổi kiến trúc thì thêm ADR mới trong `docs/adr/`. Đổi env hoặc cách deploy thì cập nhật README.

Kiểm tra nhanh vi phạm (cả ba lệnh phải không in gì):

```sh
grep -rnE "Color\(0x" lib --include=*.dart | grep -vE "app.theme|shared.design|_colors\.dart|l10n.gen"
grep -rnE "Text\((const )?['\"][^'\"$]*[A-Za-zÀ-ỹ]" lib --include=*.dart | grep -v "l10n.gen"
find lib -name '*.dart' -not -path '*/l10n/gen/*' -not -name '*.g.dart' | xargs wc -l | awk '$1>250 && $2!="total"'
```

Trên Windows hãy chạy các lệnh này trong Git Bash.

## 8. Lỗi thường gặp

| Triệu chứng | Nguyên nhân | Cách xử lý |
| --- | --- | --- |
| `app_localizations.dart` không tồn tại | Chưa sinh l10n | `flutter gen-l10n` |
| Màn hình trắng, lỗi về `API_BASE_URL` | Thiếu `--dart-define-from-file` hoặc URL sai | Chạy lại với cờ đó, kiểm tra `env/dev.json` |
| `flutter devices` không thấy Android | Emulator chưa boot xong | Chờ, chạy lại `flutter devices`; kiểm tra `adb devices` |
| Đổi `env/dev.json` mà không có tác dụng | Cấu hình là build-time | Nhấn `q`, chạy lại `flutter run` |
| Lỗi Gradle sau khi đổi Flutter/SDK | Cache cũ | `flutter clean` rồi `flutter pub get` và chạy lại |
| Đăng nhập báo lỗi mạng trên emulator | Emulator không có mạng hoặc backend không tới được | Kiểm tra mạng máy host; thử mở URL backend bằng Chrome trên emulator |

## 9. Quy trình làm việc

1. Tạo nhánh từ nhánh chính, đặt tên theo việc đang làm.
2. Đọc `AGENTS.md` trong thư mục bạn sắp sửa (nếu có) trước khi code.
3. Viết code và test cùng lúc. Mỗi view model mới cần test happy path, rỗng và lỗi.
4. Chạy bộ ba lệnh ở mục 6.
5. Cập nhật tài liệu nếu đổi hành vi, kiến trúc hay env.
6. Commit theo conventional commits (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`), rồi mở PR.

## 10. Đọc thêm

- [README](../README.md): tính năng, kiến trúc, điều hướng, công nghệ.
- [docs/adr](adr): lý do đằng sau từng quyết định kiến trúc. Bắt đầu với 0001 (kiến trúc) và 0003 (session đăng nhập).
- [docs/reports](reports): báo cáo kiểm thử và ảnh chụp từng màn hình.
- [plans](../plans): kế hoạch từng giai đoạn.
