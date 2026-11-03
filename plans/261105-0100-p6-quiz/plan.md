---
title: "P6 - Quiz thật (danh sách, làm bài, nộp, kết quả)"
description: "Thay quiz mock (1 bài cứng, lưu SharedPreferences) bằng API thật: tab Quiz có lọc chủ đề, làm quiz theo episodeSlug, nộp attempt với Idempotency-Key, kết quả + đáp án giải thích, làm mới nhiệm vụ/XP khi đạt."
status: completed
priority: P1
effort: 2.5d
branch: dev
tags: [feature, frontend, quiz]
blockedBy: []
blocks: []
created: 2026-11-05
---

# P6 - Quiz thật

Nguồn: report mục P6, 3 scout (API, RN, code Flutter) 2026-11-04. P3 (catalog) và P7 (missions, `learningActivityProvider`) đã xong nên **không bị chặn**; đóng nốt hợp đồng P7: phase 4 gọi `bump()` khi `isPassed`. **Không test, không emulator** (gom P11); test quiz cũ sẽ vỡ, sửa ở P11.

## Hợp đồng API đã xác minh (zod `packages/shared/src/schemas/quiz-mission.ts`, route `apps/api/src/modules/gamification/gamification.routes.ts`)
- `GET /api/quizzes?page&limit(1-50, mặc định 12)&topicId&episodeSlug`: **auth tùy chọn**. Khách vẫn 200 với `hasCompleted: null`. Phản hồi `{items[{id,title,description|null,episodeSlug,episodeTitle,seriesSlug,seriesTitle,topicId|null,topicName|null,posterUrl|null,questionCount,plays,hasCompleted|null}],page,limit,total}`. Server có 9 quiz.
- `GET /api/episodes/{slug}/quiz`: **cần đăng nhập** (401 `AUTH_REQUIRED`), 404 `NOT_FOUND` khi tập không có quiz. `{id,episodeId,passScorePercent,questions[{id,text,sortOrder,timeLimit|null,options[{id,label,text}]}]}`. Đáp án đúng và giải thích **không** có ở đây.
- `POST /api/quizzes/{quizId}/attempts` (201). Header `Idempotency-Key` phải là **UUID v4** (thiếu/sai → 400 `IDEMPOTENCY_KEY_REQUIRED`). Body `{answers[{questionId, optionId|null}]}`: phải trả lời đủ mọi câu, không trùng câu. Phản hồi `{id,quizId,scorePercent,isPassed,submittedAt,xpAwarded,totalXp,answers[{questionId,selectedOptionId,correctOptionId,isCorrect,explanation|null}],missions[{id,title,progress,target,completedNow,xpAwarded}]}`.
- Idempotency: cùng key + cùng body → trả lại kết quả cũ (header `Idempotent-Replayed: true`); cùng key khác body → 422 `IDEMPOTENCY_KEY_REUSED`; đang xử lý song song → 409 `IDEMPOTENCY_REQUEST_IN_PROGRESS`; lỗi ≥ 500 thì server xoá claim nên retry được.
- Làm lại không giới hạn. XP quiz (10) chỉ cộng **một lần** cho mỗi quiz (nên `xpAwarded` có thể 0 khi đạt lần sau). `hasCompleted` = có ít nhất một attempt (không phải đạt).
- Lỗi: `{error_code, message, details[]}`.

## RN (tham chiếu, `apps/mobile/src/features/heritage-app/QuizScreens.tsx`)
- Tab Quiz: chip "Tất cả chủ đề" + chip theo topic, **suy ra từ `quizzes()` limit 50** (không gọi `/api/topics`; quyết định: Flutter làm giống RN, bỏ `/api/topics` khỏi P6). Thẻ: ảnh bìa, pill topic, badge "ĐÃ HOÀN THÀNH" khi `hasCompleted == true`, `questionCount`, `plays`.
- Làm bài: `Câu X / N` + thanh tiến độ, chọn đáp án, qua câu, nộp ở câu cuối. **Bỏ qua `timeLimit`** (web mới đếm giờ). Key idempotency tạo một lần, giữ khi nộp lỗi mạng, đổi khi "Làm lại".
- Kết quả: `scorePercent`, `đúng/tổng`, "ĐÃ VƯỢT QUA"/"CHƯA ĐẠT ĐIỂM QUA", `+xpAwarded XP · Tổng totalXp XP`, xem lại từng câu (bạn chọn, đáp án đúng nếu sai, giải thích), nút Quay lại / Làm lại. Làm mới: danh sách quiz + XP.
- Khách mở quiz: màn khoá "Đăng nhập để làm quiz" → login.

## Hiện trạng Flutter (scout)
`lib/features/quiz/` 16 file ~1200 dòng, toàn mock: `QuizDefinition` cứng 6 câu (`episode == 1`), `LocalQuizRepository` + `quiz_attempt_codec.dart` (SharedPreferences), `quiz_text.dart` ánh xạ id câu cứng sang ARB, route `/episodes/:episode/quiz` nhận `int`, kiểm tra **từng câu** ("Kiểm tra đáp án" → phản hồi ngay). Tab `AppTab.quiz` đã có enum nhưng **chưa có route** trong `tabRoutes`. Không có nút quiz nào ở Player/Series (`hasQuiz` đã parse trong `EpisodeDetail`). Pattern repo/provider: `lib/shared/missions/` (Dio + `Result` + `mapDioException`), `appRetry`, `cacheFor`.

## Quyết định
1. **Bỏ kiểm tra từng câu.** API giấu đáp án đến khi nộp, nên "Kiểm tra đáp án" + `quiz_feedback_card.dart` không còn nghĩa: luồng thành chọn → câu tiếp → nộp ở câu cuối → kết quả. Đúng như RN.
2. Giữ các stage giới thiệu → câu hỏi → kết quả → xem lại (UI sẵn có, bỏ `estimatedMinutes` và thời gian làm bài vì API không có). Đạt/chưa đạt lấy từ `isPassed`, không dùng ngưỡng 80 cứng.
3. Bỏ `timeLimit` (parity RN). Ghi nhận là chênh với web.
4. Route đổi thành `/episodes/:slug/quiz` (slug String), giữ `authGuard`. Khách bấm thẻ quiz hoặc nút Làm quiz thì bị đưa tới login rồi quay lại (`returnTo`), thay cho màn khoá của RN (cùng kết quả, không thêm màn).
5. Tab Quiz công khai, thêm vào `tabRoutes` giữa Podcast và Hồ sơ; `/quizzes` là route mới.
6. Không phân trang (RN không có; `limit=50`). Giới hạn đã biết: > 50 quiz thì thiếu; hiện 9.
7. UUID v4 tự sinh bằng `Random.secure()` (không thêm gói `uuid` cho 8 dòng).
8. Feature `quiz` tự chứa domain + data + providers (chỉ quiz dùng); `learningActivityProvider` ở `core/` nên không import chéo feature.
9. Gộp `6.0` (mock tab) vào `6.3`: dữ liệu thật ngay từ đầu nên không dựng mock trung gian.

## Phases
| # | File | Nội dung | Trạng thái |
|---|---|---|---|
| 1 | [phase-01-domain-repo.md](phase-01-domain-repo.md) | domain + repo + providers + idempotency key (6.1, 6.2a) | completed |
| 2 | [phase-02-quiz-tab.md](phase-02-quiz-tab.md) | tab Quiz, lọc topic, route (6.0+6.3) | completed |
| 3 | [phase-03-attempt-flow.md](phase-03-attempt-flow.md) | màn làm quiz thật, nộp, retry cùng key (6.2b, 6.4) | completed |
| 4 | [phase-04-result-cleanup.md](phase-04-result-cleanup.md) | kết quả + xem lại, `bump()`, xoá mock (6.5, 6.6) | completed |
| 5 | [phase-05-entry-points.md](phase-05-entry-points.md) | nút Làm quiz ở Player và Series | completed |
| 6 | [phase-06-docs.md](phase-06-docs.md) | ADR, report | completed |

## Rủi ro
- `quiz_view_model.dart` và `quiz_screen.dart` viết lại gần hết (state đổi từ `List<int>` sang id UUID); phần trình bày (option tile, primitives, colors) giữ. Mỗi file ≤ 250 dòng: tách `quiz_session.dart` khỏi domain nếu cần.
- Nộp lỗi mạng giữa chừng: server có thể đã xử lý. Giữ cùng key để lần retry nhận kết quả cũ thay vì tạo attempt trùng; chỉ đổi key khi người dùng bấm Làm lại.
- `xpAwarded` có thể 0 dù đạt (đã nhận XP quiz này trước đó): giao diện không được coi 0 XP là lỗi; dùng `isPassed` quyết định đạt.
- Khi `bump()` chỉ gọi nếu `isPassed`, nhiệm vụ `PASS_QUIZ` mới nhảy. Chưa kiểm server có tính tiến độ khi trượt hay không (kết quả có `missions[]` nhưng UI bỏ qua; refresh theo `isPassed` là hợp đồng P7).
- Chưa kiểm POST thật (scout không gọi mutation); gom P11.3 bằng tài khoản `user`.
