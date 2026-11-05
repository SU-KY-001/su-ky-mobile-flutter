# Phase 7 - ADR catalog

Context: [plan.md](./plan.md). Cần phase 1-6 xong và đúng như đã code. Theo khuôn `docs/adr/0003-auth-session.md`.

## Requirements
Tạo `docs/adr/0005-catalog-layer.md` (số theo ADR kế tiếp; P2 dùng `0004`), ghi đúng những gì đã code:
- Tầng catalog đặt ở `lib/shared/catalog/{domain,data}` vì ≥ 4 feature dùng; DTO parse thủ công từng trường (không codegen), `Result` + `AppException`.
- Cache `catalogStaleTime` (60s) bằng `Ref.cacheFor`; `retry` của Riverpod 3 cấu hình tập trung (`appRetry`), không retry 4xx.
- "Tập mới" là N+1 có chặn vì thiếu endpoint danh sách tập; lỗi từng series ghi log và bỏ qua.
- Không dùng `cached_network_image`; điều kiện thêm (có ảnh thật) và ảnh dự phòng theo hash slug.
- Phần tạm chờ P4: Player và nút Phát vẫn dùng audio mock.
- Cập nhật `README.md` nếu có mô tả dữ liệu mock của Home/Search/Series (grep `mock`).
- Cập nhật `docs/reports/brainstorm-flutter-parity-with-rn.md`: chuyển episode detail sang P4.2 và topics sang P6.1, đánh dấu P2/P3 đã làm, đồng bộ mục "Bước tiếp".

## Todo
- [ ] `docs/adr/0005-catalog-layer.md`
- [ ] README + report khớp

## Success criteria
ADR khớp code phase 1-6; không chứa credential.
