# Phase 2 - Shell: AppTab, StatefulShellRoute, mini-player (tasks 2.0, 2.1, 2.2)

Context: [plan.md](./plan.md). Cần phase 1 (`ProfileScreen`, nhãn tab). Phase này là một lần cắt chuyển nguyên khối (đổi chữ ký `MainNavigation` làm vỡ mọi chỗ gọi) nên không tách nhỏ hơn.

## Requirements
**Widget (2.0)**
- `lib/shared/widgets/main_navigation.dart` mới: `enum AppTab { discover, history, podcast, quiz, profile }` (icon: `explore_outlined`, `menu_book_outlined`, `mic_none`, `emoji_events_outlined`, `account_circle_outlined`; `label(AppLocalizations l)` map sang `discover`, `tabHistory`, `tabPodcast`, `tabQuiz`, `profile`). `MainNavigation({tabs, selected, onSelect})` dùng `NavigationBar`. Xoá `MainNavigation` cũ khỏi `su_ke_widgets.dart`.
- Chuyển `MiniPlayer` sang `lib/shared/widgets/mini_player.dart` (giữ nội dung, `su_ke_widgets.dart` xuống < 200 dòng). Thêm nút tua −15s theo RN nếu `AudioViewModel` đã có `skip(-AudioDefaults.seekStepSeconds)` (đọc file; nếu chưa có thì bỏ, P4.5 làm).
- `AudioState` thêm `loaded` (mặc định `false`, vào `copyWith`); `playEpisode` và `toggle` đặt `loaded: true`. `MiniPlayer` chỉ do shell điều khiển hiển thị theo `loaded`.

**Router (2.1, 2.2)**
- `lib/app/router/app_router.dart`: `final routerProvider = Provider<GoRouter>(...)`, xoá `AppRouter.create()`. Router **không** `ref.watch` session (sẽ dựng lại router); phase 3 gắn `refreshListenable`. `ref.onDispose(router.dispose)`.
- Bản đồ một nguồn sự thật `final _tabRoutes = <AppTab, GoRoute>{AppTab.discover: <home>, AppTab.profile: <profile>}`; `tabs = _tabRoutes.keys.toList()`; nhánh = `values.map((r) => StatefulShellBranch(routes: [r]))`. Thứ tự map = thứ tự nhánh = thứ tự tab bar.
- `StatefulShellRoute.indexedStack(builder: (_, _, shell) => AppShell(navigationShell: shell, tabs: tabs), branches: ...)`.
- `lib/app/router/app_shell.dart`: `Scaffold(body: navigationShell, bottomNavigationBar: Column(mainAxisSize: min, [if (audio.loaded) MiniPlayer(onOpen: () => context.push(AppRoutes.player)), MainNavigation(...)]))`; `onSelect: (tab) { final i = tabs.indexOf(tab); navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex); }`. Đọc `AppPage` trước và giữ cùng cách đặt `bottom` (full width, không giới hạn `maxWidth`).
- Route gốc (cùng cấp shell, không `parentNavigatorKey` vì go_router mặc định đặt lên navigator gốc): `search`, `login`, `series`, `player`, `quiz`, `weeklyMissions`, `missionDetail`, `honours`. Thêm `AppRoutes.profile = '/profile'`. Không tạo route `event`/`schedule`.
- `lib/app/app.dart`: dùng `ref.watch(routerProvider)` trong `build`; bỏ `_router` và `dispose` (provider tự dispose). Giữ `ref.read(sessionControllerProvider)` hydrate ở `initState`.

**Gỡ nhúng cũ và đổi điều hướng**
- `home_screen.dart`, `search_screen.dart`, `weekly_missions_screen.dart`: bỏ `bottom:` (`MainNavigation`/`MiniPlayer`). Home: `onSearch` → `context.push(AppRoutes.search)`.
- Search và Missions giờ là route gốc nên cần nút quay lại: Missions đã có (`weekly_missions_header.dart:74`); Search thêm nút back ở header → `context.popOrGo(AppRoutes.home)`, tooltip từ ARB (kiểm key `back`/tương đương sẵn có).
- Mọi `context.push(AppRoutes.login)` dùng làm "vào hồ sơ" → `context.go(AppRoutes.profile)`: `home_header.dart:45`, `search_screen.dart:70`, `weekly_missions_header.dart:53`, `mission_widgets.dart:85` (callback cuối cùng ở `MissionTopBar`). Sau phase này `grep -rn "AppRoutes.login" lib` chỉ còn router, `login_screen.dart` và `profile_guest_card.dart`.

## Related files
Tạo: `shared/widgets/{main_navigation,mini_player}.dart`, `app/router/app_shell.dart`. Sửa: `app/router/{app_router,app_routes}.dart`, `app/app.dart`, `shared/audio/audio_view_model.dart`, `shared/widgets/su_ke_widgets.dart`, các màn/header kể trên.

## Todo
- [ ] `AppTab` + `MainNavigation` mới, `MiniPlayer` tách file, `AudioState.loaded`
- [ ] `routerProvider` + `StatefulShellRoute` + `AppShell`
- [ ] `app.dart` dùng `routerProvider`
- [ ] Gỡ nhúng tab/mini-player khỏi Home, Search, Missions; Search có nút back
- [ ] 4 chỗ vào hồ sơ → `go(AppRoutes.profile)`

## Success criteria
`flutter analyze` sạch trong `lib/`; `grep -rn "MainNavigation(" lib` chỉ còn `app_shell.dart`; `grep -rn "AppRouter.create" lib test` chỉ còn test cũ (xử lý P11); 3 lệnh grep/find ở "Verify" rỗng.

## Risks
- `go_router` 18: nếu `StatefulShellRoute.indexedStack` có chữ ký khác, đọc source trong pub cache, không đoán.
- `AudioState.loaded` chỉ là cầu tạm tới P4.5; không thêm tính năng khác vào mock audio.
