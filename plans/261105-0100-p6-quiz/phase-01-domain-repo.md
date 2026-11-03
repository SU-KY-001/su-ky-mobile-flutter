---
status: completed
---

# Phase 1 - Domain + repo + providers (tasks 6.1, 6.2a)

## Files
Viết lại trong `lib/features/quiz/`:
- `domain/quiz.dart`: thay toàn bộ mock. Thuần Dart, immutable, `final`:
  - `QuizCard` (mục catalog: các trường ở plan.md, `hasCompleted` kiểu `bool?`).
  - `QuizCatalog` (`items`, `total`).
  - `QuizOption{id,label,text}`, `QuizQuestion{id,text,sortOrder,options}` (bỏ `timeLimit`, quyết định 3), `Quiz{id,episodeId,passScorePercent,questions}`.
  - `QuizAnswer{questionId,optionId}` (body nộp, `optionId` non-null vì UI buộc chọn).
  - `QuizAnswerResult{questionId,selectedOptionId,correctOptionId,isCorrect,explanation}`, `QuizResult{scorePercent,isPassed,xpAwarded,totalXp,answers}` (bỏ `id`,`quizId`,`submittedAt`,`missions` nếu không consumer).
- `domain/quiz_stage.dart`: `QuizStage`, `QuizFilter` (chuyển ra khỏi `quiz.dart` nếu file vượt 250).
- `data/quiz_repository.dart`: `abstract class QuizRepository`, `ApiQuizRepository(Dio)`:
  - `Future<Result<QuizCatalog>> catalog({String? topicId, int limit = quizCatalogLimit})`
  - `Future<Result<Quiz>> episodeQuiz(String slug)`
  - `Future<Result<QuizResult>> submit({required String quizId, required String idempotencyKey, required List<QuizAnswer> answers})`
  Theo `lib/shared/missions/data/weekly_missions_repository.dart`: validate **từng trường** ở biên (UUID, `questions` không rỗng, mỗi câu có ≥ 2 option, `correctOptionId` thuộc tập option khi nộp thì không cần), `FormatException` → `UnknownException` + `AppLogger.error` (nguyên nhân + stack), `mapDioException`. Timeout từ `createDio`. Không log token, không log câu trả lời.
- `data/quiz_parser.dart`: tách parser nếu repo > 250 dòng.
- `data/idempotency_key.dart`: `String newIdempotencyKey()` UUID v4 bằng `Random.secure()` (đặt bit version=4, variant=10xx). Không thêm gói.
- `data/quiz_providers.dart`: `quizRepositoryProvider`; `quizCatalogProvider = FutureProvider.autoDispose.family<QuizCatalog, String?>` (key = `topicId`) với `appRetry` + `ref.cacheFor(quizCatalogCache)`; `episodeQuizProvider = FutureProvider.autoDispose.family<Quiz, String>` (slug), `appRetry`, **không** cache lâu (người dùng có thể làm lại).
- Hằng số tên: `quizCatalogLimit = 50`, `quizCatalogCache = Duration(minutes: 5)` (khớp `staleTime` RN), path `'/api/quizzes'`, `'/api/episodes'`, header `'Idempotency-Key'`. Đặt trong `data/quiz_constants.dart`.

## Lỗi
- 401 `AUTH_REQUIRED`: không retry (đã có `mapDioException`; `authGuard` chặn khách trước nên hiếm).
- 404 `NOT_FOUND` ở `episodeQuiz`: lỗi "tập này chưa có quiz", không retry.
- Nộp: 5xx/timeout/mạng → retryable; 409 `IDEMPOTENCY_REQUEST_IN_PROGRESS` → retryable (cùng key); 400/422 → không retry. Chỉ `submit` giữ key; repo không tự retry (view model quyết định, phase 3).

## Xong khi
`flutter analyze` sạch trong `lib/` (các file UI cũ chưa đụng nên tạm báo lỗi tham chiếu domain cũ là chấp nhận ở cuối phase này; phase 3-4 xử lý, cuối phase 4 phải sạch); mỗi file ≤ 250 dòng.
