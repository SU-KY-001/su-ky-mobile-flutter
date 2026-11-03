import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/features/auth/ui/login_screen.dart';
import 'package:su_ky_mobile/features/auth/ui/session_controller.dart';
import 'package:su_ky_mobile/features/home/ui/home_screen.dart';
import 'package:su_ky_mobile/features/player/ui/player_screen.dart';
import 'package:su_ky_mobile/features/podcast/ui/podcast_screen.dart';
import 'package:su_ky_mobile/features/profile/ui/profile_screen.dart';
import 'package:su_ky_mobile/features/quiz/ui/quiz_screen.dart';
import 'package:su_ky_mobile/features/search/ui/search_screen.dart';
import 'package:su_ky_mobile/features/series/ui/series_screen.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_missions_screen.dart';
import 'package:su_ky_mobile/shared/widgets/main_navigation.dart';

import 'app_routes.dart';
import 'app_shell.dart';
import 'auth_guard.dart';

/// The router lives for the whole app: never `watch` state here, it would
/// rebuild the router and reset navigation. Session changes re-run redirects
/// through `refreshListenable` instead.
final routerProvider = Provider<GoRouter>((ref) {
  final sessionChanged = ValueNotifier<int>(0);
  ref.listen(sessionControllerProvider, (_, _) => sessionChanged.value++);

  // Single source of truth for tab branches and the tab bar: a plan that adds
  // a tab adds one entry here. Map order is branch order is bar order.
  final tabRoutes = <AppTab, GoRoute>{
    AppTab.discover: GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    AppTab.podcast: GoRoute(
      path: AppRoutes.podcast,
      builder: (context, state) => const PodcastScreen(),
    ),
    AppTab.profile: GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
  };
  final tabs = tabRoutes.keys.toList();

  final router = GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: sessionChanged,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            AppShell(navigationShell: shell, tabs: tabs),
        branches: [
          for (final route in tabRoutes.values)
            StatefulShellBranch(routes: [route]),
        ],
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) =>
            LoginScreen(returnTo: AppRoutes.returnToOf(state.uri)),
      ),
      GoRoute(
        path: AppRoutes.series,
        builder: (context, state) =>
            SeriesScreen(slug: state.pathParameters['slug'] ?? ''),
      ),
      GoRoute(
        path: AppRoutes.player,
        builder: (context, state) => const PlayerScreen(),
      ),
      GoRoute(
        path: AppRoutes.quiz,
        redirect: authGuard(ref),
        builder: (context, state) => QuizScreen(
          episode: int.tryParse(state.pathParameters['episode'] ?? '') ?? -1,
        ),
      ),
      GoRoute(
        path: AppRoutes.weeklyMissions,
        builder: (context, state) => const WeeklyMissionsScreen(),
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    sessionChanged.dispose();
  });
  return router;
});
