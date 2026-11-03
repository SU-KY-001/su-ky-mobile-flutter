---
status: completed
---

# Phase 2 - Tab Quiz (tasks 6.0 + 6.3)

## Files
- `lib/features/quiz/ui/quiz_list_screen.dart` (mới): `ConsumerStatefulWidget` chỉ giữ `topicId` đang chọn (trạng thái UI tạm thời)? **Không**: quy tắc AGENTS.md để lọc trong view model → `quiz_list_view_model.dart`: `Notifier` autoDispose, state immutable `QuizListState{String? topicId}`, `select(String? topicId)`.
- `ui/quiz_topic_chips.dart`: chip "Tất cả chủ đề" + chip mỗi topic. Danh sách topic suy ra từ `quizCatalogProvider(null)` (không lọc, limit 50, cache 5 phút): duy nhất theo `topicId`, bỏ `topicId == null`, giữ thứ tự xuất hiện.
- `ui/quiz_card.dart`: thẻ: ảnh bìa (`CoverArt`, `posterUrl` có thể `null` → fallback sẵn có), pill topic, badge hoàn thành khi `hasCompleted == true` (khách `null` thì không hiện), `questionCount`, `plays`, tiêu đề, `seriesTitle · episodeTitle`. Bấm → `context.push(AppRoutes.quizFor(card.episodeSlug))`.
- `lib/app/router/app_routes.dart`: thêm `quizzes = '/quizzes'`; đổi `quiz = '/episodes/:slug/quiz'`, `quizFor(String slug)`.
- `lib/app/router/app_router.dart`: thêm `AppTab.quiz: GoRoute(path: AppRoutes.quizzes, builder: ... QuizListScreen())` vào `tabRoutes` giữa podcast và profile; sửa route quiz: `QuizScreen(slug: state.pathParameters['slug'] ?? '')`. `AppShell` tự thêm tab thứ 4 và giữ mini-player.
- `lib/l10n/app_vi.arb` + `app_en.arb`: key mới `quizListEyebrow`, `quizListTitle`, `quizAllTopics`, `quizCompletedBadge`, `quizPlays` (plural ICU), `quizListEmpty*`. `tabQuiz` đã có. Văn bản RN: "HỌC BẰNG THỬ THÁCH", "Chọn một bộ quiz để bắt đầu", "Tất cả chủ đề", "ĐÃ HOÀN THÀNH".
- Trạng thái: loading/error (retry = `ref.invalidate`)/rỗng, dùng `CatalogLoading`/`CatalogError`/`CatalogEmpty` từ `shared/widgets/catalog_states.dart`. Khách xem được danh sách (không chặn).

## Quy tắc
- Không hardcode chuỗi hiển thị, màu mới đặt ở `quiz_colors.dart`, số kích thước đặt tên (`const`).
- Màn danh sách ≤ 250 dòng; mỗi widget công khai một file.

## Xong khi
`flutter gen-l10n` chạy được, `flutter analyze` sạch trong các file mới, tab thứ 4 xuất hiện ở `AppShell`.
