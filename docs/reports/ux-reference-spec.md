# UX reference spec — copy proven patterns, do not invent

Rule: every screen copies the layout of a named reference app. No custom
component shapes. Logic, view models, repositories, routes stay as they are;
only `ui/` changes (plus tests that pinned the old layout).

Common tokens (already applied in `AppDesign`): page padding 16, card radius 12,
cover radius 8, tap target 48, nav bar 64. Mini-player is now docked
(Spotify / YouTube Music): full width, 56 high, 40 art, 1-line title, 1-line
subtitle, play/pause, 2 px progress line. Do not re-add margins around it.

Global rules
- Bottom navigation has four destinations only: Discover, Timeline, Podcast,
  Quiz. The account is an avatar button in the top-right of Home, never a tab.
- Screen title: use `AppBar` (left-aligned title 20/w700) or a plain large
  title row; never an eyebrow label above a title ("KHÁM PHÁ LỊCH SỬ",
  "HỌC BẰNG THỬ THÁCH"). Delete eyebrows and decorative subtitles.
- One primary action per screen. No full-width red buttons as navigation
  shortcuts. Shortcuts are icon buttons in the app bar or list rows.
- Lists: rows 64–72 high, thumbnail 56 square (radius 8) left, text middle,
  trailing action right. No card-in-card, no bordered card per row unless the
  reference app does it.
- Horizontal shelves: cover 140–150 square, title 2 lines max, subtitle 1 line.
  No description text inside shelf cards.
- Back: `AppBar` default back arrow. Do not draw custom round back buttons.
- Section heading: 20/w700 with optional trailing text action "Xem tất cả".
- Every tappable thing >= 48x48 and has press feedback (InkWell/ripple).
- Strings only from ARB (vi + en). Files <= 250 lines.

## Per screen

### Home (Discover) — Spotify Home
- App bar row: left title "Sử Ký" (w800, no logo tile, no "AUDIO LỊCH SỬ"
  subtitle); right icons: search (opens search), mission/trophy (opens weekly
  missions). Profile avatar removed (profile is a tab).
- Under it: filter chips row (Spotify "All / Music / Podcasts" chips) = period
  filter, first chip "Tất cả". Chips 32 high, no outer card.
- "Tiếp tục nghe" (Spotify "Jump back in" / Apple Podcasts "Up Next"): one
  compact row: 56 art, title, "series · còn X phút", trailing play icon, thin
  progress under the row. Not a bordered card with an eyebrow.
- Weekly mission teaser: Duolingo "Daily quests" row on home = one slim row
  (trophy icon, "Nhiệm vụ tuần", progress bar with "2/5", chevron). Tap opens
  missions. Replaces the giant red button. Hidden for guests if data needs login.
- Shelves (Spotify): "Series nổi bật", "Tập mới" as horizontal shelves of
  150-square covers; "Tập mới" may be list rows (Apple "Latest episodes").
- Search is NOT an inline fat field on Home; it is the app-bar icon.

### Search — Spotify Search results
- Top: `AppBar` with back arrow and an auto-focused text field (no card),
  clear (x) button. Below: recent/empty hint; results as rows
  (56 art, title, subtitle). No large cards.

### Podcast tab — Apple Podcasts "Browse" / Spotify podcast home
- Title "Podcast" in app bar. Featured series: one wide 16:9 hero with title
  overlay (Apple "Featured"), no description paragraph. Then shelf "Series"
  (150-square covers, title + "N tập"). Then "Tập mới phát hành" as list rows
  (56 art, title, series · date · duration, trailing play).

### Series detail — Spotify / Apple Podcasts show page
- Transparent/plain app bar with back. Centered 200-square cover (radius 8),
  title (22/w800), meta line "Sử Ký · 5 tập · 3 phút". Row under it:
  left small secondary actions, right a 56 circular filled play button (plays
  first playable / continues). Description max 3 lines with "Xem thêm" toggle.
- "Tất cả tập" heading, then episode rows (Spotify show page): title (2 lines),
  1–2 line description muted, meta "date · 0:35", trailing circular play icon
  (48). Quiz entry per episode: small outlined "Quiz" chip inside meta line
  or an overflow (⋮) item — never a long red text link beside the play icon.
- Remove demo/data disclaimer line if it is data, not UI.

### Player — Spotify full-screen player (podcast variant)
- Top bar: chevron-down (collapse) left, centered 2-line "Đang phát từ" /
  series title, ⋮ right (overflow: Làm quiz, Về series). 
- Large square cover (full width minus 32, radius 8). Under it title (22/w700)
  and series (muted), left aligned.
- Seek bar (thin track, small thumb) with elapsed left, remaining right.
- Controls row, evenly spaced: speed chip "1x", back 15, big 72 filled circle
  play/pause, forward 15, sleep timer. Previous/next episode only if they fit
  as the same row (Spotify podcast has none) — keep as secondary row.
- Narration (first/third person) = a segmented control under controls or in the
  ⋮ menu (Apple Podcasts "Chapters/Speed" sheet style), not a chips block.
- "Làm quiz" and "Tập tiếp theo" at the bottom as two list rows inside one
  group (Spotify "Up next" row), not outlined buttons + card.
- Remove the "Nghe lại" text button; completed state = play icon becomes
  replay icon in the main button.

### Quiz list — Duolingo "Learn" list / Kahoot discover
- App bar title "Quiz". Chips for topic (same chip style as Home). Rows: 64
  thumb (radius 8), title, "5 câu hỏi · 3 lượt chơi", trailing chevron. No
  topic pill inside every row; no card borders per row (use dividers).

### Quiz play — Duolingo lesson
- Top: close (x) left, thick rounded progress bar filling the width (10 high,
  accent), no "TIẾN ĐỘ BÀI LÀM" / "Câu 1/5" labels, no help icon, no title.
- Question text 24/w700, left aligned, no hint paragraph, no bordered card.
- Options: full-width tiles 56+ high, radius 12, 2 px border, selected = accent
  border + tint fill + radio dot (Duolingo choice tile); letter prefix "A." only
  if the data has it.
- Bottom: one sticky full-width button ("Tiếp tục" / "Nộp bài" on last), disabled
  until an option is picked (Duolingo CHECK). Server hides answers until
  submit, so do not fake per-question correct/wrong.
- Result (Duolingo "Lesson complete"): big score "4/5", XP earned if the data
  has it, primary "Tiếp tục"; "Xem lại đáp án" secondary text button; review
  rows with check/cross icons.
- Exit confirm = bottom sheet/dialog (Duolingo "Bạn muốn thoát?") kept.

### Weekly missions — Duolingo "Quests"
- AppBar with back, title "Nhiệm vụ tuần". No avatar. Top summary block: total XP
  big + "còn N ngày" + overall progress bar (Duolingo "Monthly challenge" card
  simplified). List rows: 48 icon tile, title, thick progress bar with
  "2/5" at its end, trailing XP reward chip; completed row shows check +
  muted. No card per row; use dividers.

### Profile — YouTube "You" page
- **Entry point:** the profile is NEVER a bottom-nav destination. The bottom bar
  has exactly four tabs (Discover, Timeline, Podcast, Quiz). The account opens
  from a round avatar at the top-right of the Home app row (guests: outline
  person icon; signed in: initial on the tint circle). The profile page is a
  pushed screen with the default back arrow and no bottom bar.
- **Hierarchy (YouTube "You"):** identity header → summary block → labelled
  groups. Never put identity, navigation rows, the recent list and sign-out at
  the same visual level.
  1. Header (not in a card): 72 avatar left, name 22/w800 and email muted.
  2. Summary block on a soft tinted surface (radius 12, no border): XP and
     completed missions, number over label, split by a vertical rule.
  3. Section label "Hoạt động", then one bordered group (radius 12, hairline
     border, 1 px dividers between rows) holding two 56-high rows: "Nhiệm vụ
     tuần" (trailing XP value) and "Lịch phát sóng". Each row = 40 tinted icon
     circle, 15/w600 title, muted value, chevron.
  4. Section label "Đã nghe gần đây", then flat Spotify "Recently played" rows
     (56 art, title, series · progress, progress line, trailing play) — no card.
  5. Section label "Tài khoản", then its own bordered group with a single
     destructive row "Đăng xuất" in the error color, no chevron, always behind
     a confirm dialog.
- Bell icon in the app bar still opens the release schedule.
- Guest: simple centered prompt + one filled "Đăng nhập" + secondary "Đăng ký";
  no stats, no groups, no sign-out.

### Timeline (Lịch sử) — Apple Calendar agenda / Wikipedia timeline
- App bar title "Dòng thời gian" without subtitle; period chips as on Home.
- Rail on the left (dot + year) kept; right side: compact event row (title 16/w700,
  2-line summary, optional 72x72 thumb right ONLY when an image exists).
  Delete the large pink placeholder blocks.

### Schedule — Apple Podcasts "Upcoming"
- Group by date headers (sticky-looking text header "Thứ Sáu, 6/11"), rows
  with 56 art, title, series, trailing bell/“đã phát hành” state.

### Auth — Spotify login
- Plain screen: logo/title top, fields stacked with visible labels, one filled
  submit button, mode switch as text link at bottom. No cards around the form.
