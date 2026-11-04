---
status: pending
---

# Phase 4 - Quiz, Missions, Hồ sơ, Lịch sử nghe, Lịch phát hành, Timeline (11.1c)

## Files
- **Quiz** (`test/features/quiz/`): sửa `quiz_screen_test.dart`, `quiz_view_model_test.dart` theo flow mới (theo `episodeSlug`); repo catalog + quiz + nộp bài; `Idempotency-Key` UUID v4 hợp lệ (regex), **giữ nguyên khi retry cùng một lần nộp**, đổi khi Làm lại; 401 `AUTH_REQUIRED`; 422 key dùng lại; `bump()` chỉ khi `isPassed == true`; không `bump` khi lỗi.
- **Missions** (`test/shared/missions/` + `test/features/weekly_missions/`): xoá `mission_detail_screen_test.dart` (màn đã xoá); repo parse (`items` thiếu -> lỗi cả response, `activityType`/`status` lạ -> bỏ item và ghi log), `progress` kẹp [0,1] và `targetCount == 0`, `completedCount`; provider trả `null` cho khách và không gọi API; làm mới khi `learningActivityProvider` bump; màn: loading/lỗi/rỗng/khách/có dữ liệu.
- **Hồ sơ/Lịch sử** (`test/features/profile/`, `test/shared/history/`): `profile_screen_test.dart`, `history_repository_test.dart` đã chạy được ở P8 -> chạy lại, bổ sung nếu thiếu: `percent` thập phân làm tròn/kẹp, item hỏng bị bỏ, khách không gọi API, tập `available:false` không có nút phát.
- **Lịch phát hành** (`test/features/schedule/`): đã có 3 file; chạy lại, thêm biên tháng 12->1 và `from/to` theo UTC, tháng rỗng.
- **Timeline** (`test/features/timeline/`, `test/shared/catalog/`): parser sự kiện (nhãn BCE `"Khoảng 500 TCN - ..."`, `excerpt`/`author` `null`, mục hỏng bị bỏ, sự kiện thiếu `parent.phase.name`), view model (mặc định `null`, `select` đổi state, rỗng, lỗi), màn danh sách (chọn pill gọi repo với `periodId`, rỗng, lỗi + Thử lại), màn chi tiết (có trích dẫn + series; không có series -> không có phần liên quan; `citations` rỗng; slug không tồn tại 404 + Thử lại); điều hướng dùng `router.routerDelegate.currentConfiguration.last.matchedLocation`.
- Dùng repo giả bằng `overrideWithValue`, không mạng.

## Xong khi
`flutter test test/features test/shared` xanh (trừ test `skip` do BUG), analyze 0 lỗi, report cập nhật. Mỗi view model mới đủ happy path + rỗng + lỗi (AGENTS.md).
