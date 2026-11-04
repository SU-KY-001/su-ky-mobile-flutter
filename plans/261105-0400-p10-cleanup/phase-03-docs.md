---
status: completed
---

# Phase 3 - Tài liệu

## Files
- `README.md` (136 dòng): bỏ mô tả mô phỏng/mock/placeholder (khoảng dòng 7-18, 51-56, 73-84); mô tả đúng hiện trạng (API thật, `API_BASE_URL` trong `env/dev.json` từ `env/dev.example.json`, lệnh chạy); thêm tab Lịch sử; bỏ `build_runner` và drift nếu phase 1 đã gỡ. Không thêm env mới.
- `docs/adr/0012-remove-drift-and-unused-codegen.md`: lý do gỡ (0 bảng, 0 consumer, không offline), cách thêm lại khi có consumer đầu tiên, hệ quả với `pubspec.lock`. Cập nhật dòng liên quan trong `docs/adr/0001-architecture.md` (dòng ~17, 26) trỏ tới ADR 0012.
- `AGENTS.md` (gốc): dòng 9 (`build_runner`), 34 (stack), 85 (ngoại lệ Drift) cập nhật theo phase 1; bỏ ngoại lệ Drift.
- `lib/core/AGENTS.md`: bỏ dòng `storage/ drift` trong bảng và mục offline-first (dòng ~14-19); chỉ còn `token_store`.
- `lib/features/AGENTS.md:19`: bỏ `sqflite`.
- `docs/reports/brainstorm-flutter-parity-with-rn.md`: mục P10 "ĐÃ LÀM (code xong, chưa kiểm runtime)", 10.1 ghi là đã xong từ trước (không còn mock), 10.2 xong, 10.3 xong, 10.4 chuyển P11.4; dòng "Drift" trong "Phản biện" ghi kết quả; mục 9 (bước tiếp) và dòng Status: còn P11.
- `status: completed` ở `plan.md` và các phase khi đạt tiêu chí.

## Xong khi
`dart format lib` sạch, `flutter analyze lib` sạch, 3 lệnh Verify rỗng, `flutter build apk --debug` thành công; `grep -rn "drift\|sqflite\|freezed" README.md AGENTS.md lib docs/adr` chỉ còn trong ADR 0012 và phần lịch sử.
