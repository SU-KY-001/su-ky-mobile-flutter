import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Route path constants. Never inline a path string elsewhere.
abstract final class AppRoutes {
  static const home = '/';
  static const profile = '/profile';
  static const search = '/search';
  static const login = '/login';
  static const podcast = '/podcast';
  static const quizzes = '/quizzes';
  static const series = '/series/:slug';
  static const player = '/player';
  static const quiz = '/episodes/:slug/quiz';
  static const weeklyMissions = '/weekly-missions';
  static const schedule = '/schedule';
  static const history = '/history';
  static const listeningHistory = '/listening-history';
  static const event = '/events/:slug';
  static const _returnToParam = 'returnTo';
  static String quizFor(String slug) => '/episodes/$slug/quiz';
  static String seriesFor(String slug) => '/series/$slug';
  static String eventFor(String slug) => '/events/$slug';

  /// Login location that comes back to [returnTo] after signing in.
  static String loginFor(String? returnTo) => returnTo == null
      ? login
      : Uri(
          path: login,
          queryParameters: {_returnToParam: returnTo},
        ).toString();

  /// Reads the `returnTo` query parameter of [uri], or null when it is unsafe.
  static String? returnToOf(Uri uri) =>
      safeReturnTo(uri.queryParameters[_returnToParam]);

  /// Deep links are untrusted: only in-app absolute paths that are not the
  /// login screen itself (avoids open redirects and redirect loops).
  static String? safeReturnTo(String? value) {
    if (value == null ||
        !value.startsWith('/') ||
        value.startsWith('//') ||
        value.contains(r'\') ||
        value.startsWith(login)) {
      return null;
    }
    return value;
  }
}

extension AppNavigation on BuildContext {
  /// Pops when a previous route exists, otherwise jumps to [fallback].
  void popOrGo(String fallback) => canPop() ? pop() : go(fallback);
}
