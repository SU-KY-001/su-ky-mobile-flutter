# Sử Ký

**Sử Ký** (`su_ky_mobile`) là ứng dụng Android giúp người học tiếp cận lịch sử Việt Nam qua podcast: nghe các series kể chuyện lịch sử, xem dòng thời gian sự kiện theo thời kỳ, làm quiz sau mỗi tập và nhận XP từ nhiệm vụ hằng tuần.

Nội dung (series, tập, thời kỳ, sự kiện, quiz, nhiệm vụ, lịch sử nghe, lịch phát hành) đều lấy từ REST API thật, cấu hình qua `API_BASE_URL`. Ứng dụng không có cơ sở dữ liệu cục bộ.

## Tính năng

- **Nghe podcast**: stream audio thật, phát nền kèm notification, đổi tốc độ, hẹn giờ tắt, chuyển giọng đọc, tự động lưu và khôi phục tiến độ nghe theo từng giọng.
- **Thư viện nội dung**: series, tập, thời kỳ lịch sử và tìm kiếm lấy trực tiếp từ API; trang series dạng album, có tập mới và ghi công ảnh bìa.
- **Dòng thời gian**: danh sách sự kiện lịch sử lọc theo thời kỳ; trang chi tiết có nguồn trích dẫn và các series liên quan.
- **Quiz theo tập**: màn giới thiệu, trả lời từng câu, gửi bài với `Idempotency-Key`, sau đó xem điểm và review từng câu. Kết quả đạt/không đạt và XP do server quyết định.
- **Nhiệm vụ tuần và XP**: tiến độ nhiệm vụ làm mới khi có hoạt động học tập, không polling; mỗi nhiệm vụ có hướng dẫn cách hoàn thành.
- **Tài khoản**: đăng nhập, đăng ký, đăng xuất, sửa tên và avatar; session lưu trong secure storage.
- **Hồ sơ**: thẻ XP, lịch sử nghe đầy đủ, lịch phát hành series.
- **Khách**: xem nội dung thoải mái; riêng phát audio và làm quiz cần đăng nhập, và sau khi đăng nhập sẽ quay lại đúng màn đang dở.
- **Song ngữ**: tiếng Việt mặc định, có bản dịch tiếng Anh; toàn bộ chuỗi hiển thị nằm trong ARB.

## Kiến trúc

Feature-first MVVM theo hướng dẫn App Architecture chính thức của Flutter (xem [ADR 0001](docs/adr/0001-architecture.md)):

- `ui -> domain <- data`: UI (View + ViewModel) gọi domain, data triển khai repository.
- `features/*` chỉ phụ thuộc `core`; `core` không import `features`/`app`.
- Feature không dùng chung internals của nhau — chia sẻ qua `core`, `shared` hoặc điều hướng route.
- State và DI dùng Riverpod 3, ViewModel là `Notifier` với state bất biến.
- Lỗi trả về `Result<T>` + `AppException` có kiểu, không ném exception xuyên tầng.
- Model viết tay, validate từng trường tại biên (API payload, storage); không dùng codegen.

```
lib/
  main.dart          bootstrap: error hooks, config, runApp
  app/               App widget, router, theme
  core/              config, di, error, logging, network, storage, auth
  features/<name>/   ui/ domain/ data/ — một thư mục mỗi feature
  shared/            widget và tiện ích dùng bởi >= 2 feature
  l10n/              ARB (app_vi.arb là template, app_en.arb); output ở l10n/gen (git-ignored)
test/                phản chiếu 1-1 cấu trúc lib/
docs/adr/            quyết định kiến trúc
docs/reports/        báo cáo kiểm thử, UX audit, spec tham chiếu
plans/               kế hoạch triển khai theo từng giai đoạn
```

Các feature hiện có trong `lib/features/`: `auth`, `home`, `player`, `podcast`, `profile`, `quiz`, `schedule`, `search`, `series`, `timeline`, `weekly_missions`.

## Điều hướng

Tab chính (ADR 0004): Khám phá (`/`), Dòng thời gian (`/history`), Podcast (`/podcast`), Quiz (`/quizzes`), Hồ sơ (`/profile`).

Route mở đè lên tab shell: tìm kiếm (`/search`), đăng nhập (`/login`), series (`/series/:slug`), player (`/player`), quiz của tập (`/episodes/:slug/quiz`), chi tiết sự kiện (`/events/:slug`), nhiệm vụ tuần (`/weekly-missions`), lịch phát hành (`/schedule`), lịch sử nghe (`/listening-history`).

## Công nghệ

| Nhóm | Thư viện |
| --- | --- |
| State / DI | `flutter_riverpod` 3 (không codegen) |
| Điều hướng | `go_router` |
| Mạng | `dio`, `connectivity_plus` |
| Lưu trữ | `shared_preferences`, `flutter_secure_storage` |
| Audio | `just_audio`, `just_audio_background` |
| Khác | `intl`, `image_picker`, `path_provider`, `url_launcher`, `material_symbols_icons` |

Không có local database và không có package codegen; chỉ l10n được sinh tự động (ADR 0012). Font Inter được nhúng sẵn cùng giấy phép SIL OFL (ADR 0002, ADR 0013).

## Yêu cầu môi trường

- Flutter 3.47+ / Dart 3.13+
- Android SDK và một emulator hoặc thiết bị Android có USB debugging
- Ứng dụng chỉ hỗ trợ Android; không hỗ trợ iOS hay web

## Cài đặt và chạy

```sh
flutter pub get
cp env/dev.example.json env/dev.json      # điền API_BASE_URL thật
flutter gen-l10n                          # sau khi clone hoặc sau khi sửa lib/l10n/*.arb
flutter devices
flutter run -d <android-device-id> --dart-define-from-file=env/dev.json
```

Trên Windows PowerShell, tạo file cấu hình bằng `Copy-Item env/dev.example.json env/dev.json`.

VS Code: chọn emulator/thiết bị Android, chọn cấu hình `Su Ky - Android` và nhấn F5; cấu hình này nạp `env/dev.json`.

Lưu ý khi chạy:

- URL trong `env/dev.example.json` chỉ là placeholder, phải thay bằng backend thật.
- Nếu màn hình trắng, kiểm tra lệnh chạy có `--dart-define-from-file` hay chưa: `API_BASE_URL` thiếu hoặc sai sẽ ném lỗi trước `runApp`.
- Sau khi đổi cấu hình build-time, nhấn `q` để dừng phiên chạy rồi khởi động lại.
- Generated l10n trong `lib/l10n/gen/` bị git-ignore, nên phải chạy `flutter gen-l10n` sau clone.

## Cấu hình build-time

Truyền qua `--dart-define` hoặc `--dart-define-from-file=env/<env>.json`:

| Key | Giá trị | Mặc định | Ý nghĩa |
| --- | --- | --- | --- |
| `ENV` | `dev` `staging` `prod` | `dev` | Mức log và debug banner. Giá trị sai làm app dừng ngay. |
| `API_BASE_URL` | URL http(s) tuyệt đối | không có (bắt buộc) | Gốc REST backend. Thiếu/sai làm app dừng ngay. |

`env/*.json` bị git-ignore; chỉ commit các file `env/*.example.json`.

Không đặt secret trong `--dart-define` vì giá trị bị nhúng vào binary và có thể trích xuất. Tài khoản dùng để test đặt trong `env/accounts.local.json` (git-ignored), xem mẫu ở `env/accounts.example.json`.

## Kiểm thử và chất lượng

```sh
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

Definition of done của repo: format, analyze và test đều xanh, tài liệu được cập nhật. Quy ước chi tiết nằm trong [AGENTS.md](AGENTS.md) — mọi thay đổi kiến trúc cần thêm ADR mới trong `docs/adr/`.

## Build bản phát hành

```sh
flutter build apk --release --dart-define-from-file=env/prod.json
```

APK được phân phối ngoài store. Rollback bằng cách phát hành lại APK trước đó; cấu hình chỉ tồn tại ở build-time nên không thể đổi sau khi build.

## Tài liệu

- [docs/adr](docs/adr) — 13 quyết định kiến trúc: layering, auth session, app shell, catalog, audio, đồng bộ tiến độ, nhiệm vụ, quiz, timeline, bỏ codegen, icon.
- [docs/reports](docs/reports) — báo cáo kiểm thử, UX audit, spec tham chiếu và ảnh chụp từng màn hình.
- [plans](plans) — kế hoạch từng giai đoạn P1–P12.
- [AGENTS.md](AGENTS.md) — quy ước code, layering và tiêu chuẩn bắt buộc.

## Ghi công

- Font Inter: Google Fonts, giấy phép SIL Open Font License (kèm tại `assets/fonts/Inter/OFL.txt`).
- Ảnh bìa dự phòng: nguồn, tác giả và giấy phép ghi trong [assets/images/CREDITS.md](assets/images/CREDITS.md).
