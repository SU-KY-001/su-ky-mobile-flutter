---
title: "P10 - Dọn dẹp và chốt"
description: "Gỡ phụ thuộc không dùng (drift, freezed, json_serializable, path), thống nhất tên app trong l10n, sửa README/AGENTS đã cũ, ADR cho quyết định gỡ Drift. Không test, không emulator."
status: completed
priority: P2
effort: 0.5d
branch: dev
tags: [cleanup, docs]
blockedBy: []
blocks: []
created: 2026-11-05
---

# P10 - Dọn dẹp và chốt

Nguồn: report mục P10, 3 scout (mock, Verify/l10n, docs/Drift) ngày 2026-11-05, kiểm lại bằng grep.
Quy ước: **không viết test, không chạy emulator** (test cũ vỡ để P11).

## Đã xác minh (không cần làm)
- Không còn file/class mock trong `lib/` (task 10.1 của report đã xong từ P3-P9). Test cũ vỡ (`widget_test.dart`, `dio_factory_test.dart`, `audio_view_model_test.dart`, 3 test quiz/missions) **để P11**, không đụng.
- 3 lệnh Verify rỗng; file lớn nhất 218 dòng; không TODO/FIXME; mọi duration đã là hằng có tên.
- Khoá ARB vi/en khớp 188/188. `env/*.json` đã bị `.gitignore`.

## Phát hiện cần làm
- Drift: `@DriftDatabase(tables: [])`, `databaseProvider` không có consumer (`core/di/providers.dart:42-46`, `core/storage/app_database.dart`).
- `freezed_annotation`, `json_annotation`, `path`, `freezed`, `json_serializable`: 0 import trong `lib/` và `test/` (đã grep lại; chỉ `app_database.dart` import drift).
- Tên app: `appName` vi = "Sử Kế", `AppConfig.appName` = "Sử Ký", en = "Su Ke", nhưng `playerSeriesLine` = "Sử Ký / Su Ky" (vi/en không nhất quán).
- `app_en.arb` thiếu 5 khối `@metadata` có ở `app_vi.arb` (`episodeMinutes`, `missionsProgressRatio`, `missionsWeekEnd`, `missionsXpReward`, `seriesEpisodeCount`).
- README còn mô tả mô phỏng/mock, thiếu tab Lịch sử, nhắc drift. `AGENTS.md` dòng 9, 34, 85, `lib/core/AGENTS.md` (bảng storage + mục offline-first), `lib/features/AGENTS.md:19` (sqflite) đã cũ.

## Quyết định cần bạn duyệt (chốt trước khi chạy)
1. **Gỡ Drift** (khuyến nghị): không tính năng nào cần SQLite. Giữ + ADR "dùng đầu tiên" chỉ là hứa suông. Gỡ rồi thêm lại khi cần.
2. **Tên app**: "Sử Ký" (khớp tên repo, `AppConfig`) hay "Sử Kế" (có thể là tên trong Figma). Scout không xác minh được nguồn; mặc định đổi toàn bộ sang **Sử Ký / Su Ky**.
3. **Gỡ freezed/json_serializable/path**: khuyến nghị gỡ (0 consumer). `build_runner` vẫn cần nếu còn codegen khác; sau khi gỡ drift_dev/freezed/json_serializable thì không còn codegen nào, nên gỡ cả `build_runner` và lệnh trong README/AGENTS.

## Phase
| # | Phase | Kết quả | Trạng thái |
|---|---|---|---|
| 1 | [phase-01-deps-drift.md](phase-01-deps-drift.md) | gỡ Drift và package không dùng | completed |
| 2 | [phase-02-l10n.md](phase-02-l10n.md) | tên app thống nhất, metadata en | completed |
| 3 | [phase-03-docs.md](phase-03-docs.md) | README, AGENTS, ADR 0012, report | completed |

## Rủi ro / chưa kiểm
- Gỡ package đổi `pubspec.lock` (mất ~10 phụ thuộc bắc cầu); build APK phải qua.
- Chưa chạy app; không có smoke.
- `just_audio_background` hay package khác có thể dựa vào `path` bắc cầu: `pub get` tự giữ nếu cần.
