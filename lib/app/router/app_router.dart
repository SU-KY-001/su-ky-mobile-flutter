import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/features/auth/ui/login_screen.dart';
import 'package:su_ky_mobile/features/home/ui/home_screen.dart';
import 'package:su_ky_mobile/features/player/ui/player_screen.dart';
import 'package:su_ky_mobile/features/search/ui/search_screen.dart';
import 'package:su_ky_mobile/features/series/ui/series_screen.dart';

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
          onBack: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.home),
          onPlayer: () => context.push(AppRoutes.player),
        ),
      ),
      GoRoute(
        path: AppRoutes.player,
        builder: (context, state) => PlayerScreen(
          onBack: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.home),
          onSeries: () => context.push(AppRoutes.series),
        ),
      ),
    ],
  );
}
