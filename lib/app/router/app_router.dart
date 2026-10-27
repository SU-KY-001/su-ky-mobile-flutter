import 'package:go_router/go_router.dart';

import '../../features/home/ui/home_screen.dart';
import 'app_routes.dart';

/// Single place that declares every route. Features expose screens; they never
/// call `GoRouter` constructors themselves.
abstract final class AppRouter {
  static GoRouter create() => GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}
