import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/features/auth/ui/login_screen.dart';
import 'package:su_ky_mobile/features/auth/ui/session_controller.dart';
import 'package:su_ky_mobile/features/home/ui/home_screen.dart';
import 'package:su_ky_mobile/features/player/ui/player_screen.dart';
import 'package:su_ky_mobile/features/podcast/ui/podcast_screen.dart';
import 'package:su_ky_mobile/features/profile/ui/listening_history_screen.dart';
import 'package:su_ky_mobile/features/profile/ui/profile_screen.dart';
import 'package:su_ky_mobile/features/quiz/ui/quiz_list_screen.dart';
import 'package:su_ky_mobile/features/quiz/ui/quiz_screen.dart';
// import 'package:su_ky_mobile/features/schedule/ui/schedule_screen.dart';
import 'package:su_ky_mobile/features/search/ui/search_screen.dart';
import 'package:su_ky_mobile/features/series/ui/series_screen.dart';
import 'package:su_ky_mobile/features/timeline/ui/event_detail_screen.dart';
import 'package:su_ky_mobile/features/timeline/ui/timeline_screen.dart';
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
    AppTab.history: GoRoute(
      path: AppRoutes.history,
      builder: (context, state) => const TimelineScreen(),
    ),
    AppTab.podcast: GoRoute(
      path: AppRoutes.podcast,
      builder: (context, state) => const PodcastScreen(),
    ),
    AppTab.quiz: GoRoute(
      path: AppRoutes.quizzes,
      builder: (context, state) => const QuizListScreen(),
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
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.listeningHistory,
        redirect: authGuard(ref),
        builder: (context, state) => const ListeningHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        redirect: loginGuard(ref),
        builder: (context, state) =>
            LoginScreen(returnTo: AppRoutes.returnToOf(state.uri)),
      ),
      GoRoute(
        path: AppRoutes.series,
        builder: (context, state) =>
            SeriesScreen(slug: state.pathParameters['slug'] ?? ''),
      ),
      GoRoute(
        path: AppRoutes.event,
        builder: (context, state) =>
            EventDetailScreen(slug: state.pathParameters['slug'] ?? ''),
      ),
      GoRoute(
        path: AppRoutes.player,
        builder: (context, state) => const PlayerScreen(),
      ),
      GoRoute(
        path: AppRoutes.quiz,
        redirect: authGuard(ref),
        builder: (context, state) =>
            QuizScreen(slug: state.pathParameters['slug'] ?? ''),
      ),
      GoRoute(
        path: AppRoutes.weeklyMissions,
        builder: (context, state) => const WeeklyMissionsScreen(),
      ),
      // Release schedule is hidden: no screen links to it. Uncomment this route,
      // the import above, and re-add the profile bell / "Lịch phát sóng" row to restore.
      // GoRoute(
      //   path: AppRoutes.schedule,
      //   builder: (context, state) => const ScheduleScreen(),
      // ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    sessionChanged.dispose();
  });
  return router;
});
