/// Route path constants. Never inline a path string elsewhere.
abstract final class AppRoutes {
  static const home = '/';
  static const search = '/search';
  static const login = '/login';
  static const series = '/series/bach-dang-938';
  static const player = '/player';
  static const quiz = '/episodes/:episode/quiz';
  static String quizFor(int episode) => '/episodes/$episode/quiz';
}
