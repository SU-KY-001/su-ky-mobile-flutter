# Phase 1 - Nền tảng Android + gói + khởi tạo (task 4.1)

Context: [plan.md](./plan.md). Đọc `AGENTS.md` (root), `lib/core/AGENTS.md`. Không có Dart logic ở phase này.

## Requirements
**pubspec** (`flutter pub add`, ghi `pubspec.lock`): `just_audio`, `just_audio_background`. Sau `flutter pub get` đọc `pubspec.lock` để ghi đúng phiên bản vào ADR; nếu ràng buộc SDK của gói không chấp nhận Dart 3.13 / Flutter 3.47 thì dừng, báo bạn.

**`android/app/src/main/AndroidManifest.xml`** (đang chỉ có `INTERNET`): thêm
- quyền `WAKE_LOCK`, `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK`, `POST_NOTIFICATIONS`;
- trong `<application>`: `<service android:name="com.ryanheise.audioservice.AudioService" android:foregroundServiceType="mediaPlayback" android:exported="true">` với intent-filter `android.media.browse.MediaBrowserService`; `<receiver android:name="com.ryanheise.audioservice.MediaButtonReceiver" android:exported="true">` với intent-filter `android.intent.action.MEDIA_BUTTON`;
- thêm `xmlns:tools` vào `<manifest>` nếu dùng `tools:ignore="Instantiatable"`.
Đối chiếu từng dòng với README của `audio_service` đúng phiên bản trong `pubspec.lock` (đọc trong pub cache), không chép theo trí nhớ.

**`MainActivity.kt`** (`android/app/src/main/kotlin/com/example/su_ky_mobile/`): `class MainActivity : AudioServiceActivity()`. Thêm `MethodChannel` `NOTIFICATION_PERMISSION_CHANNEL` với method `request`: nếu `Build.VERSION.SDK_INT < 33` hoặc đã được cấp thì trả `true` ngay; ngược lại `requestPermissions(arrayOf(POST_NOTIFICATIONS), REQUEST_CODE)` và trả kết quả trong `onRequestPermissionsResult`. Giữ một `Result` đang chờ duy nhất; gọi lần hai khi chưa xong thì trả `false`. Hằng tên kênh và request code đặt tên ở đầu file Kotlin.

**Dart**
- `lib/core/platform/notification_permission.dart`: `Future<bool> requestNotificationPermission()` gọi channel; `PlatformException`/`MissingPluginException` → `AppLogger.error` kèm cause/stack và trả `false` (có thể phát mà không có thông báo). Timeout bằng hằng.
- `lib/shared/audio/audio_defaults.dart`: thêm `notificationChannelId`, `pendingPlayTtl`, `playbackSpeeds`, `localPositionSaveInterval = 3s`, `resumeMinSeconds = 1`, `resumeEndMarginSeconds = 2`; **xoá** `tickInterval`.
- `lib/main.dart`: sau `ensureInitialized()` và trước `runApp`, `await JustAudioBackground.init(androidNotificationChannelId: AudioDefaults.notificationChannelId, androidNotificationChannelName: lookupAppLocalizations(const Locale('vi')).audioChannelName, androidNotificationOngoing: true)`. Chỉ gọi một lần. Lỗi init đi vào `runZonedGuarded` sẵn có.
- ARB (vi + en): `audioChannelName` ("Phát podcast" / "Podcast playback").

## Verify
`flutter pub get`, `flutter gen-l10n`, `dart format lib`, `flutter analyze` sạch trong `lib/`, **`flutter build apk --debug` thành công** (bắt lỗi ghép manifest và tương thích Gradle). Không chạy app.

## Risks / security
- Gói beta: nếu build lỗi vì AGP 9.1/Kotlin 2.4, ghi nguyên văn lỗi, dừng và hỏi (hướng dự phòng: `audio_service` trực tiếp với `AudioHandler`, tốn thêm 1-2 ngày).
- `android:exported="true"` bắt buộc cho `AudioService`/`MediaButtonReceiver`; không thêm intent-filter ngoài README.
- Không log tên/nội dung quyền ngoài mã trạng thái.

## Todo
- [x] Thêm hai gói và khoá phiên bản
- [x] Manifest: quyền, service, receiver
- [x] `MainActivity` đổi sang `AudioServiceActivity` + channel xin quyền thông báo
- [x] `notification_permission.dart`, hằng trong `audio_defaults.dart`
- [x] `JustAudioBackground.init` trong `main.dart` + ARB `audioChannelName`
- [x] `flutter analyze` sạch; `flutter build apk --debug` thành công
