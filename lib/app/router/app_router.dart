import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/features/auth/ui/login_screen.dart';
import 'package:su_ky_mobile/features/home/ui/home_screen.dart';
import 'package:su_ky_mobile/features/player/ui/player_screen.dart';
import 'package:su_ky_mobile/features/quiz/ui/quiz_screen.dart';
import 'package:su_ky_mobile/features/search/ui/search_screen.dart';
import 'package:su_ky_mobile/features/series/ui/series_screen.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/honours_screen.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/mission_detail_screen.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_missions_screen.dart';

import 'app_routes.dart';

abstract final class AppRouter {
  static GoRouter create() => GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.series,
        builder: (context, state) => const SeriesScreen(),
      ),
      GoRoute(
        path: AppRoutes.player,
        builder: (context, state) => const PlayerScreen(),
      ),
      GoRoute(
        path: AppRoutes.quiz,
        builder: (context, state) => QuizScreen(
          episode: int.tryParse(state.pathParameters['episode'] ?? '') ?? -1,
        ),
      ),
      GoRoute(
        path: AppRoutes.missionDetail,
        builder: (context, state) => const MissionDetailScreen(),
      ),
      GoRoute(
        path: AppRoutes.honours,
        builder: (context, state) => const HonoursScreen(),
      ),
      GoRoute(
        path: AppRoutes.weeklyMissions,
        builder: (context, state) => const WeeklyMissionsScreen(),
      ),
    ],
  );
}
