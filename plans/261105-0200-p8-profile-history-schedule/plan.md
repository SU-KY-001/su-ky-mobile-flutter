---
title: "P8 - Hồ sơ đầy đủ, Lịch sử nghe, Lịch phát sóng"
description: "Hồ sơ có thẻ XP + nhiệm vụ đã xong, mục 'Đã nghe gần đây' có nút nghe tiếp (API thật), màn Lịch phát sóng theo tháng với trạng thái trống. Giống RN, không thêm lọc/phân trang."
status: completed
priority: P2
effort: 2d
branch: dev
tags: [feature, frontend, profile, history, schedule]
blockedBy: []
blocks: []
created: 2026-11-05
---

# P8 - Hồ sơ, Lịch sử nghe, Lịch phát sóng

Nguồn: report mục P8 + 3 scout (API, RN `AccountScreens.tsx`, code Flutter) ngày 2026-11-05. P5 và P7 đã `completed` nên không bị chặn. **Không test, không emulator** (gom vào P11), trừ test mới của plan này (phase 4).

## Hợp đồng API đã xác minh (schema thật: `packages/shared/src/schemas/listening/index.ts`, `showcase.ts`)
- `GET /api/me/listening-history?page=&limit=&status=` cần đăng nhập (401). `limit` 1–50, `status` `all|in_progress|completed`. Trả `{items[], page, limit, total}`; mỗi item: `episode{id,slug,title,available,series{slug,title}}`, `lastListenedAt`, `lastNarrationId`, `lastPositionMs`, `percent` (0–100), `isCompleted`. Rỗng = 200 `items: []`.
- `GET /api/showcase/releases?from=&to=` **công khai**, `from` gồm, `to` loại trừ, `to-from` ≤ 62 ngày (vượt = 400 `VALIDATION_ERROR`). Item: `id,title,scheduledAt,released,episodeSlug,series{id,title,slug}`. Dữ liệu thật tháng 10 và 11/2026 đang **rỗng** → trạng thái trống là đường chạy chính.
- Weekly missions đã có (P7): `weeklyMissionsProvider` ở `shared/missions`, có `totalXp`, `completedCount`.

## Hành vi RN cần giống (`AccountScreens.tsx:21-232`)
- Hồ sơ: header + chuông → Lịch; thẻ người dùng/khách; banner XP + số nhiệm vụ xong; "Đã nghe gần đây" (limit 10, status `all`, không phân trang, không lọc); mỗi dòng: tên tập, `series · Đã nghe {percent}%`, thanh tiến độ, nút nghe tiếp. Khách: không gọi history/missions.
- Lịch: chuyển tháng ±1, nhãn "Tháng M, YYYY"; loading / lỗi + thử lại / trống "Chưa có lịch phát trong tháng này"; mỗi dòng: ngày, tiêu đề tập, series, nhãn Đã phát hành / Sắp ra mắt, nút nghe **chỉ khi `released`**.

## Quyết định
1. **Bỏ 8.0a/b/c (dựng mock trước)**: nối API thật ngay (như P6). Mock sẽ bị thay ngay trong plan.
2. **Hồ sơ không lặp danh sách nhiệm vụ**: Flutter đã có màn `/weekly-missions` (P7). Hồ sơ chỉ có thẻ XP + "N nhiệm vụ đã xong", bấm vào → `AppRoutes.weeklyMissions`. Lệch RN (RN liệt kê nhiệm vụ ngay trong Hồ sơ) nhưng tránh nhân đôi UI và tránh import chéo `features/weekly_missions` (cấm bởi AGENTS.md).
3. **Lịch sử nghe nằm trong Hồ sơ**, không tab riêng (RN cũng vậy). Không lọc trạng thái, không phân trang (RN không có; report cũ ghi "lọc, phân trang" là vượt parity, **sửa report**). Cố định `limit=10`, `status=all` bằng hằng số.
4. **Dữ liệu history ở `lib/shared/history/`** (Hồ sơ dùng, và tự làm mới theo `learningActivityProvider` của P5). Lịch ở `lib/features/schedule/` (chỉ màn đó dùng).
5. **Nút nghe tiếp** = `playFromUi(context, ref, episode.slug, narrationId: lastNarrationId)`. Vị trí tiếp lấy từ `progress.positionMs` do endpoint playback trả (P5 đã xử lý), **không** dùng `lastPositionMs` để seek. Tập `available == false` thì không hiện nút nghe (RN không kiểm tra; API cờ này nghĩa là tập/series không còn xuất bản, phát sẽ lỗi).
6. **Tháng của Lịch**: `from` = đầu tháng, `to` = đầu tháng sau, tính theo giờ địa phương rồi `toUtc().toIso8601String()` (≈ RN). Luôn < 62 ngày. Tháng đang xem là state của `ScheduleViewModel` (Notifier bất biến), không dùng `setState`.
7. **Lịch công khai**: khách vẫn xem được; nút nghe đi qua `playFromUi` nên khách bị hỏi đăng nhập như mọi nơi.
8. **Tab Lịch sử (`AppTab.history`) không đụng**: thuộc P9.

## Phases
| # | Phase | Trạng thái |
|---|---|---|
| 1 | [Domain + repo + provider lịch sử](phase-01-history-data.md) (8.2a) | completed |
| 2 | [Hồ sơ: thẻ XP, Đã nghe gần đây, chuông](phase-02-profile.md) (8.1, 8.2b) | completed |
| 3 | [Màn Lịch phát sóng](phase-03-schedule.md) (8.3) | completed |
| 4 | [Test + tài liệu](phase-04-tests-docs.md) | completed |

## Rủi ro / chưa kiểm
- Chưa gọi history thật (cần tài khoản); gom P11.3 bằng tài khoản `user` trong `env/accounts.local.json`.
- Chưa thấy dòng release thật nào (cả hai tháng rỗng): UI có dữ liệu chỉ kiểm bằng test + schema.
- `percent` có thể là số thập phân (ví dụ 82.18): parse bằng `num`, hiển thị làm tròn.
- Tập `isCompleted` nhưng `percent < 100` có thể xảy ra (đếm theo narration khác): hiển thị theo `percent`, không suy ra từ `isCompleted`.
- Test cũ của repo đang vỡ (P11); test mới của plan này phải tự biên dịch và chạy được riêng (`flutter test <file>`).

## Đã kiểm với dữ liệu thật (2026-11-05, đăng nhập tài khoản role `user` trong `env/accounts.local.json`, chỉ GET)
- Sign-in 200, có header `set-auth-token`.
- `listening-history?status=all`: 200, có item thật (ví dụ "Khởi nghĩa Lam Sơn", `percent` 7.142857…, `lastPositionMs` 12502, `available: true`, series "Việt Nam thời phong kiến"). Đúng schema; `percent` thập phân xác nhận → phải làm tròn. `status=completed`: `items: []`, `total: 0`.
- `weekly-missions`: 200 nhưng `items: []`, `totalXp: 0` cho tài khoản này (tuần bắt đầu `2026-11-01T17:00Z` = thứ Hai giờ VN). Thẻ XP phải hiển thị tốt khi 0 XP và 0 nhiệm vụ (không coi là lỗi/ẩn).
- `showcase/releases`: **rỗng mọi tháng từ 2026-01 đến 2027-01** (13 tháng, cả khi đăng nhập). Không có dòng release thật nào để thử; UI lịch có dữ liệu chỉ kiểm bằng test.
