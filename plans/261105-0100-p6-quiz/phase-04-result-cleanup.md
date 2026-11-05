---
status: completed
---

# Phase 4 - Kết quả + xem lại + làm mới + dọn mock (tasks 6.5, 6.6)

## Kết quả (`quiz_summary_view.dart`)
- Điểm `scorePercent`, `đúng/tổng` (đếm `isCorrect`), trạng thái từ `isPassed` ("Đã vượt qua"/"Chưa đạt điểm qua", bỏ ngưỡng 80 cứng và "Excellent"), dòng `+{xpAwarded} XP · Tổng {totalXp} XP` (ICU placeholder). `xpAwarded == 0` vẫn hiện bình thường (XP quiz chỉ cộng một lần).
- Bỏ thẻ "Thời gian làm bài" và "Thống kê chi tiết" nếu chỉ chứa dữ liệu client-side (API không có).
- Nút: Xem lại đáp án, Làm lại (`retake()`), Quay lại (`leaveQuiz()`: về `/quizzes` nếu không có back stack, thay cho `AppRoutes.player` cũ).

## Xem lại (`quiz_review_view.dart`, `quiz_review_item.dart`)
Mỗi câu: nội dung, "Bạn chọn: {label}. {text}", "Đáp án đúng: {label}. {text}" khi sai, `explanation` nếu có. Bộ lọc tất cả/sai/đúng giữ như hiện có. Dữ liệu ghép từ `Quiz.questions` + `QuizResult.answers` theo `questionId`; thiếu cặp thì bỏ câu đó và `AppLogger` ghi (validate ở biên).

## Làm mới (hợp đồng với P7)
Khi `submit` thành công, trong view model:
- luôn `ref.invalidate(quizCatalogProvider)` (`hasCompleted`, `plays` đổi);
- chỉ khi `result.isPassed`: `ref.read(learningActivityProvider.notifier).bump()` (nhiệm vụ `PASS_QUIZ` + XP làm mới qua `weeklyMissionsProvider`). Đây là mục "7.2" còn mở phía P6.

## Dọn mock (6.6)
Xoá: `data/quiz_attempt_codec.dart`, `LocalQuizRepository`, `QuizDefinition`, `QuizAttempt` cũ, key SharedPreferences `quiz.*.latest` (không cần migrate: dữ liệu giả); `test/features/quiz/data/quiz_repository_test.dart` (kiểm tra code đã xoá; xoá, không viết lại ở đây). Các test UI/view model cũ để P11 viết lại theo luồng mới. ARB: xoá key chỉ phục vụ mock (`quizQuestion1..6` nếu còn, `quizCategory`, `quizSource`, `quizTipBody`...).

## Xong khi
`dart format lib`, `flutter analyze` sạch trong `lib/`, 3 lệnh Verify của `AGENTS.md` rỗng, `flutter gen-l10n` chạy được, `grep -rn "QuizDefinition\|LocalQuizRepository\|quiz_attempt_codec\|quizQuestion[0-9]" lib` rỗng.
