# Lưu ý khi giao việc cho Command Code (headless)

Dùng khi tôi (agent) hoặc bạn chạy `commandcode -p` để triển khai plan. Kiểm lại bằng `commandcode --help` nếu bản CLI đổi.

## Lệnh chuẩn
```sh
cat .cmcd-<plan>-prompt.txt | commandcode -p --yolo --verbose --trust --skip-onboarding --tools-all --max-turns 250
```
- `-p`: chạy không tương tác, in kết quả rồi thoát.
- `--yolo`: bỏ qua mọi hỏi quyền (chạy trong repo này, đã có git để hoàn tác).
- `--trust`: tự tin tưởng dự án, bỏ prompt quyền ban đầu.
- `--skip-onboarding`: bỏ màn onboarding taste (chạy tự động).
- `--tools-all`: bật mọi tool, kể cả tool mà chế độ headless mặc định giấu (theo `--help`: "-p: enable every tool, including the ones a headless run withholds"). Muốn bật chọn lọc thì dùng `--tools-enable <tên,tên>`.
- `--verbose`: in tiến trình tool ra stderr.
- `--max-turns 250`: mặc định chỉ 100 lượt; chạm trần thì thoát **mã 8** dù có thể đã làm gần xong (P6 bị vậy).
- Windows: dùng `commandcode`; `cmd` là Command Prompt của Windows, không phải Command Code.

## Chọn model và mức suy nghĩ
- Cờ: `-m <model>` và `--effort <low|medium|high>` (phụ thuộc model). Danh sách model: `commandcode --list-models`. Mặc định hiện là `minimax/minimax-m3.1-flash` (effort `medium`, lưu trong `~/.commandcode/config.json`).
- Đã dùng: `-m deepseek/deepseek-v4.1-flash --effort high` (id đã xác nhận bằng `--list-models`; hỏi lại CLI nếu tên đổi).
- Lý do đổi (P9, 2026-11-04): MiniMax chạy rất lâu. Bảng usage cho thấy mỗi lượt gọi sinh 5.500–17.800 token đầu ra, mất 39–121 giây, và ngữ cảnh đầu vào phình từ 151K lên 220K token trong 6 phút. Chậm là do sinh nhiều và ngữ cảnh dài, không phải kẹt. DeepSeek chưa có số liệu so sánh: ghi thêm thời gian và kết quả sau khi chạy xong.
- Lệnh đầy đủ khi chọn model:
```sh
cat .cmcd-<plan>-prompt.txt | commandcode -p -m deepseek/deepseek-v4.1-flash --effort high --yolo --verbose --trust --skip-onboarding --tools-all --max-turns 250
```

## Chạy dở, dừng và tiếp tục
- Dừng job: `write proc://<job>/kill`. Các file đã sửa vẫn nằm trong cây làm việc.
- Prompt tiếp tục phải ghi rõ: đây là lần chạy tiếp, dùng `git status` và `git diff` để xem phần đã làm, **không làm lại hay ghi đè**, sửa chỗ sai rồi hoàn thành phần thiếu. Cấm đụng `.gitignore`. Có thể bảo nó chạy `flutter analyze lib` trước để thấy file dở.
- Plan lớn mà chậm: chia prompt theo phase để ngữ cảnh đỡ phình (đổi lại phải review nhiều lần).

## Kiểm xem có đang chạy không (không poll)
- Một lần kiểm là đủ khi người dùng hỏi: `proc://<job>` cho trạng thái; transcript `~/.commandcode/projects/<tên-thư-mục-dự-án>/<session>.jsonl` được ghi liên tục khi còn chạy (so giờ sửa file với `date`); `git status` cho file đã đổi.
- Chưa thấy file đổi sau vài phút là bình thường: nó đọc `AGENTS.md`, plan, ADR và test mẫu trước khi viết.
- Coi là kẹt khi transcript ngừng ghi, hoặc quá khoảng 30 phút mà `lib/` chưa đổi.
- Trong bash trên Windows, không dán lệnh PowerShell có `$_` (bash mở rộng sai); viết ra file `.ps1` hoặc dùng `eval`.
- Lần đầu chạy, Command Code tự thêm `.commandcode/` vào `.gitignore`: chấp nhận được, nhưng đọc diff trước khi commit.

## Cách đưa prompt
- **Không viết test (quy ước P1–P10, báo cáo parity mục 5):** prompt phải ghi rõ "không viết, không chạy test; test để P11". P9 từng vi phạm vì tôi đưa phase test vào plan và prompt; đã xoá 4 file test. Khi lập plan, đọc mục "Quy ước kiểm thử" của `docs/reports/brainstorm-flutter-parity-with-rn.md` trước, không suy từ `AGENTS.md`.
- Ghi prompt ra file tạm bằng tool `write`, rồi `cat file | commandcode -p ...`. **Không** dùng `type file |` trong bash (file không tìm thấy, báo "No query provided").
- Chạy nền (`async`, `timeout` 3600) rồi chờ kết quả, không poll.
- Prompt phải có: đường dẫn plan + phase, đọc `AGENTS.md` trước, cấm gọi API production và cấm emulator, các lệnh kiểm (`gen-l10n`, `dart format`, `flutter analyze lib`, 3 lệnh Verify, test mới, `flutter build apk --debug`), và yêu cầu báo cáo cuối (file đổi, lệch plan, chưa kiểm).
- Xoá file prompt tạm sau khi chạy (đừng commit `.cmcd-*`).

## Sau khi chạy xong (đừng tin báo cáo)
1. Chạy lại độc lập: `flutter analyze lib`, test mới, 3 lệnh Verify, `git status`.
2. Đọc diff thật, đặc biệt phần logic (view model, repo). Command Code đã từng báo xong khi còn sót bước.
3. Nếu thoát mã 8: kiểm trạng thái plan/file trước khi chạy lại, tránh làm lại từ đầu.
4. Chỉ commit sau khi kiểm xong; commit theo từng plan.

## Taste
- `.commandcode/taste/` hiện **trống**, `commandcode taste list` báo không có package. Chưa có `tasteLearning` trong `~/.commandcode/config.json` (mặc định là bật theo tài liệu).
- Taste học từ chấp nhận / từ chối / sửa. Tôi **suy ra** (chưa có tài liệu xác nhận) rằng `-p --yolo` không tạo tín hiệu nên taste không ghi gì.
- Cách có dữ liệu:
  - `commandcode taste enable` (bật cho dự án).
  - `commandcode taste learn .` học từ repo hiện tại, hoặc `commandcode taste learn owner/repo`.
  - `commandcode learn-taste` học từ các phiên trước; `/learn-taste` trong phiên tương tác học từ phiên của agent khác (Claude Code, Cursor).
  - Dùng chế độ tương tác (`commandcode`, không `-p`) cho việc cần dạy taste.
- Kiểm: `commandcode taste list`, `npx taste lint`.
