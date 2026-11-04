---
title: "P7 - Nhiệm vụ tuần + XP (thật, không Vinh danh)"
description: "Thay mock nhiệm vụ bằng GET /api/me/weekly-missions: tổng XP, danh sách nhiệm vụ với tiến độ; tự làm mới khi hoàn thành tập/đạt quiz; xoá Vinh danh, chi tiết nhiệm vụ và dữ liệu giả."
status: completed
priority: P2
effort: 1.5d
branch: dev
tags: [feature, frontend, gamification]
blockedBy: [261104-2359-p5-progress-sync]
blocks: []
created: 2026-11-05
---

# P7 - Nhiệm vụ tuần + XP

Nguồn: report mục P7 (đã bỏ Vinh danh theo chốt 2026-11-04), scout API + RN + code Flutter 2026-11-04. **Bị chặn bởi P5** ở phase 3 (cần `learningActivityProvider` ở `lib/core/activity/`); phase 1-2 làm được trước nhưng cứ làm sau P5 cho gọn. **Không test, không emulator** (gom vào P11).

## Hợp đồng API đã xác minh
`GET /api/me/weekly-missions[?weekStartDate=]`, cần đăng nhập (401 `AUTH_REQUIRED`/`UNAUTHORIZED`). Phản hồi: `{weekStartDate, weekEndDate, totalXp, items[{id, title, activityType, targetCount, progressCount, xpReward, completedAt|null, weekStartDate, weekEndDate, status}]}`.
- `activityType`: `COMPLETE_EPISODE` | `PASS_QUIZ`. `status`: `IN_PROGRESS` | `COMPLETED` | `EXPIRED`. Tuần neo thứ Hai 00:00 Asia/Ho_Chi_Minh; `weekEndDate` là mốc hết tuần (UTC instant).
- XP cộng ở server: hoàn thành tập +10 một lần/tập (P5), đạt quiz (P6), hoàn thành nhiệm vụ +`xpReward` một lần. `totalXp` ở phản hồi này là nguồn XP duy nhất cho UI.
- Mỗi `quizId` chỉ tính một lần mỗi tuần cho nhiệm vụ `PASS_QUIZ`.

## RN (tham chiếu)
Không có màn riêng. `AccountScreens.tsx` (Hồ sơ): ô "Tổng điểm XP" + "Nhiệm vụ xong" (đếm `status==COMPLETED`), mục "Nhiệm vụ tuần này": mỗi dòng icon (`award` cho PASS_QUIZ, `headphones` cho COMPLETE_EPISODE), tiêu đề, thanh tiến độ, `progress/target`. Khách hoặc rỗng thì không hiện. Làm mới: RN chỉ invalidate sau nộp quiz; **không** sau hoàn thành tập (Flutter làm cả hai).

## Quyết định (đơn giản theo yêu cầu "chỉ nhiệm vụ rồi tăng XP")
1. Giữ **một** màn `WeeklyMissionsScreen` dạng danh sách; **xoá** màn chi tiết nhiệm vụ (`MissionDetailScreen` + route `missionDetail`): nội dung của nó (mục tiêu 01/02/03, "khảo cứu điển tích", ấn thưởng) là dữ liệu bịa, API không có.
2. **Xoá** lịch điểm danh/streak (`weekDates`, `checkedInDays`, `streakDays`) và `MissionKind` kiểu `explore/journey/streak`: API không có.
3. Hồ sơ (8.1) dùng lại `weeklyMissionsProvider` của P7; P7 không đụng Hồ sơ.
4. Model và repo nằm ở `lib/shared/missions/{domain,data}` (như `shared/catalog`) vì Hồ sơ và màn nhiệm vụ cùng dùng; feature không import ruột feature khác.
5. `activityType` hoặc `status` ngoài tập giá trị đã biết: bỏ item đó, ghi log (xác thực tại ranh giới, giống catalog); chỉ lỗi cả khối khi phản hồi thiếu `items`/`totalXp`.
6. Tiêu đề nhiệm vụ lấy nguyên từ API (`title` do server soạn, không phải chuỗi giao diện); nhãn khung (Tổng XP, Nhiệm vụ tuần, Hết hạn...) vẫn qua ARB.

## Phases
| # | File | Nội dung | Trạng thái |
|---|---|---|---|
| 1 | [phase-01-domain-repo.md](phase-01-domain-repo.md) | domain + repo + providers (tasks 7.1a) | completed |
| 2 | [phase-02-ui.md](phase-02-ui.md) | viết lại màn danh sách, nối thật (7.1b) | completed |
| 3 | [phase-03-refresh-cleanup.md](phase-03-refresh-cleanup.md) | tự làm mới (7.2) + xoá Vinh danh/chi tiết/mock (7.3) | completed |
| 4 | [phase-04-docs.md](phase-04-docs.md) | ADR, report | completed |

## Rủi ro
- Màn hiện có nặng mock (header có nút huy hiệu, widget thẻ chi tiết); viết lại nhiều hơn sửa. Giữ lại chỉ phần thuần trình bày dùng được (thanh tiến độ, thẻ), không giữ logic giả.
- Làm mới qua `learningActivityProvider` chỉ bắt được sự kiện trong app; XP đổi từ nơi khác (web) chỉ cập nhật khi vào lại màn (provider `autoDispose`).
- Quiz (P6) chưa có: phase 3 ghi chú P6 phải `bump()` khi `isPassed`; P6 plan phải có việc này. Nếu P6 làm xong trước P7, thêm vào đó ngay.
- Tuần mới (qua thứ Hai) khi app mở: không tự đổi tuần, cần vào lại màn.
