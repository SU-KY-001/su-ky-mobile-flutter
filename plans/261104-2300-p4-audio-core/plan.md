---
title: "P4 - Phát audio cốt lõi (just_audio, phát nền, cổng khách)"
description: "Thay audio mock bằng PlaybackController thật: phát một tập qua API, phát nền có điều khiển ở thông báo, Player + MiniPlayer nối controller, đổi ngôi kể, tốc độ, hẹn giờ ngủ, cổng khách, nhớ vị trí cục bộ."
status: completed
priority: P1
effort: 5d
branch: dev
tags: [feature, frontend, audio, android]
blockedBy: []
blocks: []
created: 2026-11-04
---

# P4 - Phát audio cốt lõi

Nguồn: report mục P4 (tasks 4.0-4.9), 4 scout (API, RN, code Flutter, gói `just_audio`) ngày 2026-11-04. P2 và P3 đã `completed` nên không bị chặn. **Không test, không emulator ở P4** (gom vào P11); mốc = `dart format`, `flutter analyze` sạch trong `lib/`, 3 lệnh grep/find "Verify" của `AGENTS.md` rỗng. **Ngoại lệ duy nhất:** phase 1 phải qua `flutter build apk --debug` (xem Rủi ro 1). Chưa gửi tiến độ lên server (thuộc P5).

## Hợp đồng API đã xác minh (2026-11-04)
| Endpoint | Khách | Trường dùng ở P4 |
|---|---|---|
| `GET /api/episodes/{slug}` | 200 | `id, slug, title, description?, publishedAt?, series{id,slug,title,cover{url}?}, narrations[{id,type FIRST_PERSON/THIRD_PERSON,narrator?,durationMs?,available}], previousEpisode{id,slug,title}?, nextEpisode{id,slug,title}?, hasQuiz`. Bỏ qua `entities, publicationInfo, viewer, series.sources` (không consumer). 404 `NOT_FOUND` khi slug sai. |
| `GET /api/narrations/{id}/playback` | **200 (đã gọi thật)** | `narrationId, episodeId, audio{assetId,url,mimeType,durationMs}`. `progress` (khách = `null`) và `sync{intervalMs,completionThreshold}` **không parse ở P4** (P5 dùng). 404 `CONTENT_UNAVAILABLE` khi audio chưa READY. `Cache-Control: private, no-store` nên không cache provider. |
| `GET/PUT /api/me/listening-progress/{id}` | 401 `AUTH_REQUIRED` | Không dùng ở P4. |
Dữ liệu thật: tập mẫu `dai-hoi-dang-toan-quoc-lan-thu-vi-doi-moi`, narration `acf85900-…`, 1 narration `THIRD_PERSON`, MP3 32 giây trên `res.cloudinary.com` (URL có chữ ký, `authenticated`). `previousEpisode`/`nextEpisode` = `null` ở tập đó.
**Chưa kiểm:** (a) `Accept-Ranges`/seek trên URL Cloudinary (scout không gọi thật, chỉ suy ra); (b) series nào có **hơn 1 narration** (tập mẫu chỉ có 1 ⇒ đổi ngôi kể chưa thử được trên dữ liệu thật); (c) URL có hết hạn không.

## Hành vi RN cần giữ và lỗi RN không sao chép
Giữ: chặn khách bấm Play → login → tự phát đúng tập; vị trí cục bộ `pos.<narrationId>` (lưu tối đa mỗi 3 s, chỉ khi ≥ 1 s; khôi phục nếu `> 1 s` và `< duration - 2 s`; xong tập thì lưu 0); bấm Play khi đã hết tập thì tua về 0 rồi phát; không tự chuyển tập kế; nhãn ngôi kể `FIRST_PERSON` = "Lời kể nhân vật", `THIRD_PERSON` = "Người dẫn chuyện", chỉ hiện khi có hơn 1 ngôi; thông báo lỗi (xem phase 4). MiniPlayer: ảnh 46, tiêu đề 1 dòng, phụ đề "Sử Ký · {series} · Tập {n}", -15 s, Phát/Tạm dừng, vạch tiến độ 3 px, ẩn khi đang ở Player.
Không sao chép: RN **không** phát nền/không có điều khiển khoá màn hình (code ghi "out of scope"); đổi ngôi kể về 0 (Flutter giữ vị trí theo quyết định đã chốt); không có tốc độ/hẹn giờ ngủ (Flutter làm cục bộ); RN không có yêu thích (Flutter bỏ nút yêu thích mock).

## Quyết định
1. **Gói:** `just_audio` `0.10.6` (2026-06-29, Apache-2.0) + `just_audio_background` `0.0.1-beta.17` (2025-05-13, MIT; kéo theo `audio_service`, `audio_session`). Không viết `AudioHandler`. Số phiên bản lấy từ API pub.dev; ràng buộc SDK và Gradle chưa tự xác nhận (xem phase 1).
2. **Một `AudioPlayer` toàn app** (`audioPlayerProvider`, `ref.onDispose(player.dispose)`), một `PlaybackController` (`NotifierProvider`, **không** `autoDispose`: ngoại lệ có chủ đích của quy tắc "state màn hình autoDispose", vì mini-player và phát nền sống ngoài mọi màn). Vị trí phát là provider riêng (`StreamProvider` từ `positionStream`) để thanh tua không làm rebuild toàn Player.
3. **Mọi nơi bấm Phát gọi cùng một hàm** `playEpisode(slug, {narrationId})`: cổng khách → tải `episodeDetail(slug)` (cache 60 s) → chọn narration (tham số, nếu không thì narration `available` đầu tiên; quy tắc chọn của RN **chưa đọc được**) → `GET playback` → `setAudioSource` với `MediaItem` → phát. Một đường duy nhất thay cho chỉ số tập mock.
4. **Cổng khách (4.7):** khách bấm Phát → hộp thoại (lý do RN: "Đăng nhập để nghe đầy đủ câu chuyện và lưu tiến trình cá nhân.") → đẩy `/login`. Controller giữ `pendingPlay` và nghe `sessionControllerProvider`: khi chuyển sang đã đăng nhập thì tự phát; `pendingPlay` hết hạn sau `pendingPlayTtl` (10 phút, hằng đặt tên) và bị xoá khi đăng xuất hoặc khi có yêu cầu phát khác. Lý do TTL: màn login không biết mình bị đóng không đăng nhập, RN để `pendingPlay` sống vô hạn nên đăng nhập sau đó vẫn bật nhạc bất ngờ.
5. **Quyền thông báo Android 13+ không thêm gói:** `MethodChannel` nhỏ trong `MainActivity.kt` gọi `requestPermissions(POST_NOTIFICATIONS)` (khoảng 25 dòng Kotlin) thay cho `permission_handler`. Hỏi một lần ở lần Phát đầu tiên mỗi lần chạy app; từ chối thì vẫn phát, chỉ mất thông báo. Đổi sang `permission_handler` nếu sau này cần thêm quyền khác.
6. **Đăng xuất dừng phát** và xoá `lastEpisode`. Các khoá `pos.<narrationId>` còn lại trên máy (giống RN, không chứa dữ liệu cá nhân ngoài tiến độ nghe).
7. **Hẹn giờ ngủ** giữ như mock: bật/tắt, `AudioDefaults.sleepTimerMinutes` (15). Dùng `Timer` trong controller; **chưa kiểm** nó có chạy khi app ở nền (dịch vụ foreground giữ tiến trình, nhưng Doze chưa thử). **Tốc độ** chuyển theo danh sách `playbackSpeeds = [0.75, 1.0, 1.25, 1.5, 2.0]`, mặc định 1.0 (mock đang bắt đầu ở 1.2 với bước 0.2, không khớp dải `just_audio`).
8. **Bỏ** nút yêu thích/lưu của Player mock (API không có, RN không có), cờ `AudioState.loaded`, `tickInterval`, `MockCatalog.episodeSeconds/initialPositionSeconds`, `audio_view_model.dart`.
9. **Nút "Nghe tiếp nhiệm vụ" của Missions** (từng phát tập mock số 2): đổi thành mở tab Podcast cho tới khi API nhiệm vụ cho biết tập đề xuất (P7). Chưa kiểm API nhiệm vụ có trường tập hay không.
10. **Thông báo (`MediaItem`)**: `id = narrationId`, `album = series.title`, `title = episode.title`, `artist` = nhãn ngôi kể, `artUri` = `series.cover.url` (hiện `null`, chấp nhận). Kênh thông báo: id/tên đặt hằng số; tên kênh lấy từ `lookupAppLocalizations(Locale('vi'))` vì `init` chạy trước `runApp` (quy tắc không chuỗi cứng).
11. **Không** xử lý `AudioSession` thủ công (cần khai báo `audio_session` trực tiếp): `just_audio` mặc định tự dừng khi tai nghe rút/cuộc gọi.

## Phase
| Phase | Tên | Trạng thái |
|-------|-----|-----------|
| 1 | [Nền tảng Android + gói + khởi tạo](./phase-01-platform-setup.md) | Done |
| 2 | [Episode detail + Playback: domain, data, providers](./phase-02-playback-data.md) | Done |
| 3 | [PlaybackController: phát, tua, ngôi kể, tốc độ, hẹn giờ, vị trí cục bộ](./phase-03-playback-controller.md) | Done |
| 4 | [Player + MiniPlayer + điểm vào Phát; gỡ audio mock](./phase-04-ui-wiring.md) | Done |
| 5 | [Cổng khách](./phase-05-guest-gate.md) | Done |
| 6 | [ADR audio + README + report + trạng thái plan](./phase-06-docs.md) | Done |

Thứ tự bắt buộc 1 → 2 → 3 → 4 → 5 → 6. Phase 1 chặn mọi phase sau (nếu `just_audio_background` không build được với AGP 9.1 thì dừng và đổi hướng trước khi viết controller). Phase 4 xoá `audio_view_model.dart`, nên chạy sau phase 3.

## Rủi ro
1. **Build:** AGP `9.1.0`, Kotlin `2.4.0`, Gradle `9.3.1` rất mới; `just_audio_background` là beta từ 2021 và chưa kiểm tương thích. Phase 1 chạy `flutter build apk --debug` để phát hiện lỗi ghép manifest/Gradle sớm (đây là lệch so với quy ước "không build ở P1-P10", có chủ đích).
2. **Android 14+:** thiếu `FOREGROUND_SERVICE_MEDIA_PLAYBACK` hoặc `foregroundServiceType="mediaPlayback"` thì crash ngay khi phát (theo scout; chưa tái hiện).
3. **Đổi ngôi kể chưa thử trên dữ liệu thật** (chỉ có tập 1 narration). Chỉ kiểm bằng test giả ở P11.
4. **Hết hạn URL Cloudinary** chưa rõ; xử lý: lỗi phát thì gọi lại `playback` một lần (phase 3).
5. **Tests cũ** tham chiếu mock audio (`quiz_screen_test`, `quiz_view_model_test`, `mission_detail_screen_test`, `test/shared/audio/audio_view_model_test.dart`) sẽ vỡ; sửa/xoá ở P11, không đụng ở P4.
6. `AudioPlayer` không thể khởi tạo trong test không có platform channel: controller nhận player qua `audioPlayerProvider` để P11 ghi đè bằng giả.

## Quy ước mỗi task
Tuân thủ mục "Enforced standards" của `AGENTS.md`: không chuỗi cứng (ARB vi+en), không số trần, file ≤ 250 dòng, state bất biến, điều hướng qua `context.push/go(AppRoutes.x)`. Chỉ dùng `read`/`edit`/`write` để sửa file.

## Tiêu chí hoàn thành
- Đã đăng nhập: bấm Phát ở chi tiết series phát đúng MP3 thật; Player và MiniPlayer cùng một trạng thái; thoát app/tắt màn hình vẫn phát và có điều khiển ở thông báo (kiểm ở P11).
- Khách: bấm Phát thấy hộp thoại, đăng nhập xong tự phát đúng tập.
- Không còn `audio_view_model.dart`, không còn `MockCatalog` audio; `flutter analyze` sạch trong `lib/`.
