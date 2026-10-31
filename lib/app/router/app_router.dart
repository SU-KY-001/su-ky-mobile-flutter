import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:su_ky_mobile/shared/audio/audio_view_model.dart';

import 'app_routes.dart';

abstract final class AppRouter {
  static GoRouter create() => GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => HomeScreen(
          onSearch: () => context.go(AppRoutes.search),
          onSeries: () => context.push(AppRoutes.series),
          onPlayer: () => context.push(AppRoutes.player),
          onProfile: () => context.push(AppRoutes.login),
        ),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => SearchScreen(
          onHome: () => context.go(AppRoutes.home),
          onProfile: () => context.push(AppRoutes.login),
          onSeries: () => context.push(AppRoutes.series),
          onPlayer: () => context.push(AppRoutes.player),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => LoginScreen(
          onClose: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.home),
          onContinue: () => context.go(AppRoutes.home),
        ),
      ),
      GoRoute(
        path: AppRoutes.series,
        builder: (context, state) => SeriesScreen(
          onQuiz: (episode) => context.push(AppRoutes.quizFor(episode)),
          onBack: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.home),
          onPlayer: () => context.push(AppRoutes.player),
        ),
      ),
      GoRoute(
        path: AppRoutes.player,
        builder: (context, state) => PlayerScreen(
          onQuiz: (episode) => context.push(AppRoutes.quizFor(episode)),
          onBack: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.home),
          onSeries: () => context.push(AppRoutes.series),
        ),
      ),
      GoRoute(
        path: AppRoutes.quiz,
        builder: (context, state) => QuizScreen(
          episode: int.tryParse(state.pathParameters['episode'] ?? '') ?? -1,
          onClose: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.player),
          onEpisode: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.player),
        ),
      ),

      GoRoute(
        path: AppRoutes.missionDetail,
        builder: (context, state) => MissionDetailScreen(
          onBack: () => context.canPop()
              ? context.pop()
              : context.go(AppRoutes.weeklyMissions),
          onHonours: () => context.push(AppRoutes.honours),
          onProfile: () => context.push(AppRoutes.login),
          onListen: () {
            ProviderScope.containerOf(context)
                .read(audioViewModelProvider.notifier)
                .playEpisode(MissionDetailScreen.recommendedEpisode);
            context.push(AppRoutes.player);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.honours,
        builder: (context, state) => HonoursScreen(
          onBack: () => context.canPop()
              ? context.pop()
              : context.go(AppRoutes.weeklyMissions),
          onDiscover: () => context.go(AppRoutes.home),
          onProfile: () => context.push(AppRoutes.login),
        ),
      ),
      GoRoute(
        path: AppRoutes.weeklyMissions,
        builder: (context, state) => WeeklyMissionsScreen(
          onMissionDetail: () => context.push(AppRoutes.missionDetail),
          onHonours: () => context.push(AppRoutes.honours),
          onBack: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.home),
          onHome: () => context.go(AppRoutes.home),
          onSearch: () => context.go(AppRoutes.search),
          onLibrary: () => context.go(AppRoutes.weeklyMissions),
          onProfile: () => context.push(AppRoutes.login),
        ),
      ),
    ],
  );
}
