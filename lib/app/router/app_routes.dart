import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Route path constants. Never inline a path string elsewhere.
abstract final class AppRoutes {
  static const home = '/';
  static const search = '/search';
  static const login = '/login';
  static const series = '/series/bach-dang-938';
  static const player = '/player';
  static const quiz = '/episodes/:episode/quiz';
  static const weeklyMissions = '/weekly-missions';
  static const missionDetail = '/weekly-missions/listening';
  static const honours = '/weekly-missions/honours';
  static String quizFor(int episode) => '/episodes/$episode/quiz';
}

extension AppNavigation on BuildContext {
  /// Pops when a previous route exists, otherwise jumps to [fallback].
  void popOrGo(String fallback) => canPop() ? pop() : go(fallback);
}
