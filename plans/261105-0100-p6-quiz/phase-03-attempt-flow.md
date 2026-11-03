---
status: completed
---

# Phase 3 - Màn làm quiz thật + nộp (tasks 6.2b, 6.4)

## Files (viết lại trong `lib/features/quiz/ui/`)
- `quiz_view_model.dart`: `AsyncNotifier<QuizSession>` autoDispose family theo `slug` (String). `build()`: đọc `episodeQuizProvider(slug)` (lỗi → `AsyncError`, màn hiện `CatalogError` có retry). Phương thức:
  - `start()`: `playbackControllerProvider.notifier.pause()` (giữ hành vi hiện có), sinh `attemptKey = newIdempotencyKey()` nếu chưa có, stage `question`, `index = 0`.
  - `select(String optionId)`: chỉ ở stage `question`, chỉ nhận id thuộc câu hiện tại; ghi `answers[questionId] = optionId`.
  - `next()`: cần đã chọn; không phải câu cuối thì `index + 1`; câu cuối thì `submit()`.
  - `submit()`: bỏ qua nếu `submitting`; `answers` theo thứ tự `sortOrder` từ `Quiz.questions`; gọi `QuizRepository.submit` với **`attemptKey` hiện giữ**. `Ok` → stage `result`, lưu `result`; `Err` → ở lại câu cuối với `submitError` (không đổi key) để bấm "Thử lại" gọi lại `submit()`.
  - `retake()`: key mới, xoá đáp án và kết quả, về stage `question` (hoặc `introduction`), `index = 0`.
  - `review()`, `summary()`, `filter(QuizFilter)`, `abandon()`: giữ như cũ.
  Sau `await` luôn kiểm `ref.mounted`.
- `quiz_session.dart` (mới, nếu cần): `QuizSession` immutable: `quiz`, `stage`, `index`, `answers` (`Map<String,String>` bọc `Map.unmodifiable`), `attemptKey`, `submitting`, `submitError` (`AppException?`), `result`, `filter`. Dẫn xuất: `question`, `selectedOptionId`, `isLast`, `correctCount`.
- `quiz_screen.dart`: tham số `slug`, `PopScope` giữ hộp xác nhận thoát khi đang ở `question` (hiện có `confirmQuizExit`). Stage → view; không còn `episode: int`.
- `quiz_intro_view.dart`: dữ liệu thật: `questions.length`, `passScorePercent`; bỏ `quizEstimate`, `quizPrevious`, `quizTip` mock. `quiz_episode_card.dart`: đọc `episodeDetailProvider(slug)` (cache sẵn từ Player/Series); ẩn card khi chưa có dữ liệu thay vì chặn.
- `quiz_question_view.dart` + `quiz_option_tile.dart`: bỏ trạng thái "đã kiểm tra" và `quiz_feedback_card.dart` (quyết định 1); nút "Câu tiếp" / ở câu cuối "Nộp bài"; khi `submitting` thì nút khoá + vòng tải; `submitError` hiện thông báo (map từ `AppException`, qua ARB) + nút Thử lại. Nhãn đáp án lấy `option.label` từ API (A/B/C/D), nội dung từ `option.text`.
- Xoá: `quiz_feedback_card.dart`, `quiz_text.dart`.
- ARB: thêm `quizSubmit`, `quizSubmitting`, `quizSubmitFailed`, `quizLoadFailed`, `quizNotFound`; bỏ key mock không còn dùng (xác định theo grep từng key sau khi sửa UI, không xoá theo cảm giác).

## Lưu ý
- Không có timer (quyết định 3): giữ `timeLimit` ngoài model.
- Thoát giữa chừng không lưu gì (RN không lưu): bỏ lưu local.
- Đáp án chọn rồi vẫn cho đổi đến khi bấm Câu tiếp (không khoá).
- Không điều hướng trực tiếp từ view model; màn gọi `context`.

## Xong khi
`flutter analyze` sạch (chưa gồm test), file nào cũng ≤ 250 dòng, `grep "QuizDefinition\|LocalQuizRepository\|quizText" lib` rỗng sau phase 4.
