import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:su_ky_mobile/app/app.dart';
import 'package:su_ky_mobile/app/router/app_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/core/auth/signed_in.dart';
import 'package:su_ky_mobile/core/di/app_retry.dart';
import 'package:su_ky_mobile/core/di/providers.dart';
import 'package:su_ky_mobile/core/error/result.dart';
import 'package:su_ky_mobile/features/auth/ui/session_controller.dart';
import 'package:su_ky_mobile/features/quiz/data/quiz_repository.dart';
import 'package:su_ky_mobile/features/quiz/domain/quiz.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/playback_providers.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_repository.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode_detail.dart';
import 'package:su_ky_mobile/shared/catalog/domain/historical_event.dart';
import 'package:su_ky_mobile/shared/catalog/domain/historical_period.dart';
import 'package:su_ky_mobile/shared/catalog/domain/paged.dart';
import 'package:su_ky_mobile/shared/catalog/domain/series.dart';
import 'package:su_ky_mobile/shared/widgets/main_navigation.dart';

import '../support/fake_audio_player.dart';
import '../support/stub_http.dart';

class _EmptyCatalog implements CatalogRepository {
  @override
  Future<Result<Paged<SeriesSummary>>> listSeries({
    int page = 1,
    int limit = 20,
    String? query,
    String? periodId,
    String? eventId,
  }) async => const Ok(Paged(items: [], page: 1, limit: 20, total: 0));
  @override
  Future<Result<List<HistoricalPeriod>>> periods() async => const Ok([]);
  @override
  Future<Result<List<HistoricalEvent>>> events({String? periodId}) async =>
      const Ok([]);
  @override
  Future<Result<List<LatestEpisode>>> latestEpisodes() async => const Ok([]);
  @override
  Future<Result<SeriesDetail>> seriesDetail(String slug) =>
      throw UnimplementedError();
  @override
  Future<Result<EpisodeDetail>> episodeDetail(String slug) =>
      throw UnimplementedError();
  @override
  Future<Result<HistoricalEvent>> eventDetail(String slug) =>
      throw UnimplementedError();
}

class _QuizRepo implements QuizRepository {
  @override
  Future<Result<QuizCatalog>> catalog({
    String? topicId,
    int limit = 50,
  }) async => const Ok(QuizCatalog(items: [], total: 0));
  @override
  Future<Result<Quiz>> episodeQuiz(String slug) async => const Ok(
    Quiz(
      id: 'q',
      episodeId: 'e',
      passScorePercent: 70,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'Câu hỏi một',
          sortOrder: 1,
          options: [
            QuizOption(id: 'a', label: 'A', text: 'x'),
            QuizOption(id: 'b', label: 'B', text: 'y'),
          ],
        ),
      ],
    ),
  );
  @override
  Future<Result<QuizResult>> submit({
    required String quizId,
    required String idempotencyKey,
    required List<QuizAnswer> answers,
  }) => throw UnimplementedError();
}

StubReply _handler(RequestOptions o, {required bool wrongPassword}) {
  if (o.path.endsWith('sign-in/email')) {
    if (wrongPassword) {
      return const StubReply(401, {'code': 'INVALID_EMAIL_OR_PASSWORD'});
    }
    return const StubReply(
      200,
      {
        'user': {'id': 'u1', 'name': 'An', 'email': 'an@example.com'},
      },
      headers: {'set-auth-token': 'tok'},
    );
  }
  return const StubReply(200, {});
}

Future<(WidgetTester, ProviderContainer)> _launch(
  WidgetTester tester, {
  bool wrongPassword = false,
  Map<String, String> secure = const {},
}) async {
  FlutterSecureStorage.setMockInitialValues({...secure});
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    retry: appRetry,
    overrides: [
      appConfigProvider.overrideWithValue(testConfig),
      sharedPreferencesProvider.overrideWithValue(prefs),
      dioProvider.overrideWith(
        (ref) => stubDio(
          (o) => _handler(o, wrongPassword: wrongPassword),
          tokens: ref.watch(tokenStoreProvider),
        ).$1,
      ),
      signedInProvider.overrideWith(
        (ref) => ref.watch(sessionControllerProvider).isAuthenticated,
      ),
      audioPlayerProvider.overrideWithValue(FakeAudioPlayer()),
      catalogRepositoryProvider.overrideWithValue(_EmptyCatalog()),
      quizRepositoryProvider.overrideWithValue(_QuizRepo()),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const App()),
  );
  await tester.pumpAndSettle();
  return (tester, container);
}

String _location(ProviderContainer c) => c
    .read(routerProvider)
    .routerDelegate
    .currentConfiguration
    .last
    .matchedLocation;

AppLocalizations _l(WidgetTester t) =>
    AppLocalizations.of(t.element(find.byType(Scaffold).first));

/// `cacheFor` keeps 60 s timers alive; unmount and advance time so the test
/// ends with none pending.
void _test(
  String name,
  Future<void> Function(WidgetTester) body, {
  bool skip = false,
}) {
  testWidgets(name, (tester) async {
    await body(tester);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(minutes: 10));
  }, skip: skip);
}

void main() {
  group('safeReturnTo', () {
    test('keeps in-app absolute paths only', () {
      expect(AppRoutes.safeReturnTo('/episodes/a/quiz'), '/episodes/a/quiz');
      for (final bad in [
        null,
        '',
        'https://evil.test',
        '//evil.test',
        'episodes/a',
        r'/\evil',
        '/login',
        '/login?returnTo=/x',
      ]) {
        expect(AppRoutes.safeReturnTo(bad), isNull, reason: '$bad');
      }
    });

    test('loginFor round-trips through returnToOf', () {
      final login = AppRoutes.loginFor('/episodes/a/quiz?x=1');
      expect(AppRoutes.returnToOf(Uri.parse(login)), '/episodes/a/quiz?x=1');
      expect(AppRoutes.loginFor(null), AppRoutes.login);
    });
  });

  group('shell', () {
    _test('four tabs switch routes', (tester) async {
      final (_, c) = await _launch(tester);
      expect(_location(c), '/');
      expect(find.byType(NavigationDestination), findsNWidgets(4));
      for (final (icon, path) in [
        (AppTab.history.icon, '/history'),
        (AppTab.podcast.icon, '/podcast'),
        (AppTab.quiz.icon, '/quizzes'),
        (AppTab.discover.icon, '/'),
      ]) {
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.byIcon(icon),
          ),
        );
        await tester.pumpAndSettle();
        expect(_location(c), path, reason: '$icon');
      }
    });

    _test('profile is not a tab and opens from the home avatar', (
      tester,
    ) async {
      final (_, c) = await _launch(tester);
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(_l(tester).profile),
        ),
        findsNothing,
      );

      await tester.tap(find.byTooltip(_l(tester).profileTitle));
      await tester.pumpAndSettle();

      expect(_location(c), AppRoutes.profile);
      expect(find.byType(NavigationBar), findsNothing);
    });
  });

  group('auth guard', () {
    _test('a guest opening a quiz is sent to login with returnTo', (
      tester,
    ) async {
      final (_, c) = await _launch(tester);
      c.read(routerProvider).go(AppRoutes.quizFor('bach-dang'));
      await tester.pumpAndSettle();
      expect(_location(c), AppRoutes.login);
      final uri = c
          .read(routerProvider)
          .routerDelegate
          .currentConfiguration
          .uri;
      expect(AppRoutes.returnToOf(uri), '/episodes/bach-dang/quiz');
    });

    _test('signing in returns to the quiz', (tester) async {
      final (_, c) = await _launch(tester);
      c.read(routerProvider).go(AppRoutes.quizFor('bach-dang'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'an@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'pw12345678');
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      expect(_location(c), '/episodes/bach-dang/quiz');
      expect(
        find.text('Câu hỏi một'),
        findsNothing,
        reason: 'intro stage first, questions come after Start',
      );
    });

    _test('a wrong password keeps the user on login with an error', (
      tester,
    ) async {
      final (_, c) = await _launch(tester, wrongPassword: true);
      c.read(routerProvider).go(AppRoutes.login);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'an@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'wrong-password');
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      expect(_location(c), AppRoutes.login);
      expect(find.text(_l(tester).authWrongCredentials), findsOneWidget);
    });

    _test('a stored session is not mistaken for a guest at start', (
      tester,
    ) async {
      final (_, c) = await _launch(
        tester,
        secure: {
          'auth.token': 'tok',
          'auth.user': '{"id":"u1","name":"An","email":"an@example.com"}',
        },
      );
      c.read(routerProvider).go(AppRoutes.quizFor('bach-dang'));
      await tester.pumpAndSettle();
      expect(_location(c), '/episodes/bach-dang/quiz');
    });

    _test('an unsafe returnTo is ignored after sign-in', (tester) async {
      final (_, c) = await _launch(tester);
      c.read(routerProvider).go(AppRoutes.loginFor('https://evil.test'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'an@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'pw12345678');
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      expect(_location(c), AppRoutes.home);
    });
  });

  group('login screen', () {
    _test('signing in from the profile card returns to the profile', (
      tester,
    ) async {
      final (_, c) = await _launch(tester);
      c.read(routerProvider).go(AppRoutes.profile);
      await tester.pumpAndSettle();
      await tester.tap(find.text(_l(tester).profileSignInNow));
      await tester.pumpAndSettle();
      expect(_location(c), AppRoutes.login);
      await tester.enterText(find.byType(TextField).at(0), 'an@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'pw12345678');
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      expect(_location(c), AppRoutes.profile);
    });
    _test('the login form is empty on a later visit', (tester) async {
      final (_, c) = await _launch(tester);
      final l = _l(tester);

      c.read(routerProvider).go(AppRoutes.profile);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.profileSignInNow));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'an@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'pw12345678');
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      expect(_location(c), AppRoutes.profile);

      final signOut = find.text(l.profileSignOut);
      await tester.ensureVisible(signOut);
      await tester.tap(signOut);
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(l.profileSignOut),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.profileSignInNow));
      await tester.pumpAndSettle();

      expect(_location(c), AppRoutes.login);
      final fields = tester.widgetList<EditableText>(find.byType(EditableText));
      expect(
        fields.map((field) => field.controller.text),
        everyElement(isEmpty),
      );
    });

    // The server answers RESET_PASSWORD_DISABLED until it has a mail sender,
    // so the sign-in form must not offer password recovery.
    _test('login form has no forgot-password action', (tester) async {
      final (_, c) = await _launch(tester);
      c.read(routerProvider).go(AppRoutes.login);
      await tester.pumpAndSettle();
      expect(find.text(_l(tester).password), findsOneWidget);
      expect(find.textContaining('Quên mật khẩu'), findsNothing);
      expect(find.textContaining('Forgot password'), findsNothing);
    });
  });
}
