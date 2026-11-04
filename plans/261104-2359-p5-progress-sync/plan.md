---
title: "P5 - Đồng bộ tiến độ nghe (bitmap, resume, completion)"
description: "Gửi tiến độ nghe lên server bằng played bitmap, resume local -> server -> 0, nhận kết quả completion (XP, nhiệm vụ) và báo cho phần còn lại của app."
status: completed
priority: P1
effort: 2d
branch: dev
tags: [feature, audio, api]
blockedBy: []
blocks: [261105-0000-p7-missions-xp]
created: 2026-11-04
---

# P5 - Đồng bộ tiến độ nghe

Trạng thái: **completed** (code xong, chưa kiểm runtime; không gọi PUT thật ở P5, gom vào P11).

Nguồn: report mục P5 (5.1-5.5), 3 scout (API, RN `usePlayback.ts`, code Flutter) ngày 2026-11-04. P4 `completed` nên không bị chặn. Chặn P7: P7 lắng nghe `learningActivityProvider` do P5 tạo (phase 3). **Không test, không emulator** (gom vào P11); mốc = `dart format`, `flutter analyze` sạch trong `lib/`, 3 lệnh grep/find "Verify" của `AGENTS.md` rỗng.

## Hợp đồng API đã xác minh (đọc code API + GET playback thật, 2026-11-04)
| Mục | Giá trị |
|---|---|
| `GET /api/narrations/{id}/playback` (đăng nhập) | thêm `audio.assetId` (UUID), `sync{intervalMs:15000, completionThreshold:0.9}`, `progress: null \| {assetId, positionMs, playedBitmap, playedSeconds, percent, completedAt}`. P4 đang bỏ `assetId`, `sync`, `progress` (`playback_repository.dart` `_parse`). |
| `PUT /api/me/listening-progress/{narrationId}` | body **đúng 3 trường**: `{assetId, positionMs (int >= 0), playedBitmap (base64, <= 4096 ký tự)}`. Không gửi `durationMs`. Không có `Idempotency-Key` (server OR-merge đơn điệu, có khoá hàng). |
| Phản hồi PUT | `{narrationId, positionMs, playedSeconds, percent, completedAt, completion}`; `completion = null` trừ đúng lần chạm ngưỡng: `{xpAwarded, totalXp, missions[{id,title,progress,target,completedNow,xpAwarded}]}`. |
| Ngưỡng hoàn thành | server tự quyết: `playedSeconds >= ceil(totalSeconds * 0.9)`; +10 XP một lần mỗi tập; tăng nhiệm vụ `COMPLETE_EPISODE`. Client không tính. |
| Bitmap | `totalSeconds = ceil(durationMs/1000)`, `bytes = ceil(totalSeconds/8)`, byte `floor(sec/8)`, bit `1 << (sec % 8)` (LSB trước), base64 chuẩn có padding. Dài hơn `bytes` => 422. |
| Chống gian lận | bit mới chỉ được cộng trong ngân sách `ceil(elapsed*2.0) + 30`; vượt thì bị bỏ lặng lẽ (không lỗi). |
| Lỗi | 409 `AUDIO_CHANGED` (assetId cũ), 409 `WRITE_CONFLICT` (retry), 422 `PROGRESS_INVALID` (position > duration, base64 sai, bitmap dài), 429 `RATE_LIMITED` (20 lần/60 s, header `Retry-After`), 404 `CONTENT_UNAVAILABLE`, 401. |

## Hành vi RN giữ / không sao chép
Giữ: đặt bit theo từng giây khi phát; **tua thì đặt lại điểm tham chiếu** nên giây bị nhảy qua không được đánh dấu; chỉ đếm khi `0 < delta <= 5` s; sync theo `max(5000, intervalMs)`, khi tạm dừng; bảo vệ `dirty`/`saving`; lỗi thì giữ `dirty` để thử lại; ưu tiên resume local (> 1 s và < duration - 2 s) rồi server rồi 0 (đã có phần local ở P4, `_startPosition`).
Không sao chép: RN không sync khi hết bài/unmount (web có) — Flutter flush khi `completed`, khi đổi ngôi kể/dừng; RN không làm mới nhiệm vụ khi hoàn thành — Flutter phát tín hiệu qua `learningActivityProvider`.

## Quyết định
1. Bitmap thuần Dart (`dart:convert` base64), không thêm package.
2. Không nạp lại bitmap server vào client: server OR-merge, gửi lại bit cũ chỉ tốn ngân sách. Client chỉ gửi bit của phiên nghe này.
3. Logic sync nằm trong lớp `ProgressSync` riêng (không `part`), vì `playback_controller.dart` đang 244/250 dòng; controller chỉ gọi vài dòng. Nếu vẫn vượt, chuyển một method sang `playback_controller_lifecycle.dart`.
4. Khách không sync (`signedInProvider` false): `ProgressSync` im lặng.
5. 409 `AUDIO_CHANGED`: tắt sync cho narration này tới lần tải playback kế (ghi log), không retry. 422: bỏ bitmap hiện tại, ghi log. 429/5xx/mạng: giữ `dirty`, thử lại ở lần tick sau (không retry vòng).

## Phases
| # | File | Nội dung | Trạng thái |
|---|---|---|---|
| 1 | [phase-01-bitmap-and-models.md](phase-01-bitmap-and-models.md) | `PlayedBitmap`, mở rộng `PlaybackInfo` + parse | completed |
| 2 | [phase-02-sync-repo-scheduler.md](phase-02-sync-repo-scheduler.md) | `updateProgress`, `ProgressSync`, nối controller | completed |
| 3 | [phase-03-resume-completion.md](phase-03-resume-completion.md) | resume 3 tầng, `learningActivityProvider`, completion | completed |
| 4 | [phase-04-docs.md](phase-04-docs.md) | ADR 0007, cập nhật report | completed |

## Rủi ro
- `playback_controller.dart` sát giới hạn 250 dòng.
- Tick vị trí của `just_audio` là ~200 ms, chưa kiểm khi tốc độ 2x và màn hình tắt (Doze có thể làm Timer trễ; bitmap vẫn đúng vì tính theo vị trí, chỉ gửi trễ).
- Pause/seek liên tục có thể chạm 429 (20/60 s): flush khi tạm dừng chỉ khi `dirty`, và không flush khi seek.
- Chưa kiểm PUT thật (không gọi PUT trong lúc scout để khỏi đổi dữ liệu tài khoản thử); gặp ở P11.3.
