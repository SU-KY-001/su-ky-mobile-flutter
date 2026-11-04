import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/app/theme/app_theme.dart';
import 'package:su_ky_mobile/core/auth/session_user.dart';
import 'package:su_ky_mobile/core/auth/signed_in.dart';
import 'package:su_ky_mobile/core/error/app_exception.dart';
import 'package:su_ky_mobile/core/error/result.dart';
import 'package:su_ky_mobile/features/auth/ui/session_controller.dart';
import 'package:su_ky_mobile/features/profile/ui/history_tile.dart';
import 'package:su_ky_mobile/features/profile/ui/profile_history_section.dart';
import 'package:su_ky_mobile/features/profile/ui/profile_screen.dart';
import 'package:su_ky_mobile/features/profile/ui/profile_xp_card.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/history/data/history_repository.dart';
import 'package:su_ky_mobile/shared/history/domain/listening_history.dart';
import 'package:su_ky_mobile/shared/history/history_providers.dart';
import 'package:su_ky_mobile/shared/missions/data/weekly_missions_repository.dart';
import 'package:su_ky_mobile/shared/missions/domain/weekly_missions.dart';
import 'package:su_ky_mobile/shared/missions/missions_providers.dart';

class _FakeSession extends SessionController {
  _FakeSession(this._user);

  final SessionUser? _user;

  @override
  SessionState build() => SessionState(hydrated: true, user: _user);
}

class _HistoryRepository implements HistoryRepository {
  _HistoryRepository(this._responses);

  final List<Result<ListeningHistory>> _responses;
  int calls = 0;

  @override
  Future<Result<ListeningHistory>> recent() async {
    final index = calls < _responses.length ? calls : _responses.length - 1;
    calls++;
    return _responses[index];
  }
}

class _MissionsRepository implements WeeklyMissionsRepository {
  _MissionsRepository(this._missions);

  final WeeklyMissions _missions;

  @override
  Future<Result<WeeklyMissions>> fetch() async => Ok(_missions);
}

const _user = SessionUser(id: 'user-1', name: 'An', email: 'an@example.com');

WeeklyMissions _missions({int totalXp = 0, int completed = 0}) =>
    WeeklyMissions(
      totalXp: totalXp,
      weekEnd: DateTime.utc(2026, 11, 8),
      items: [
        for (var index = 0; index < completed; index++)
          WeeklyMission(
            id: 'mission-$index',
            title: 'Mission $index',
            activity: MissionActivity.completeEpisode,
            targetCount: 1,
            progressCount: 1,
            xpReward: 10,
            status: MissionStatus.completed,
          ),
      ],
    );

HistoryEntry _entry({
  String slug = 'episode-1',
  String title = 'Episode one',
  String series = 'Series A',
  bool available = true,
  int percent = 7,
}) => HistoryEntry(
  episodeSlug: slug,
  episodeTitle: title,
  seriesTitle: series,
  available: available,
  narrationId: '0f8fad5b-d9cb-469f-a165-70867728950e',
  percent: percent,
  isCompleted: false,
  lastListenedAt: DateTime.utc(2026, 11, 3),
);

ListeningHistory _history(List<HistoryEntry> items) =>
    ListeningHistory(items: items, total: items.length);

GoRouter _router() => GoRouter(
  initialLocation: AppRoutes.profile,
  routes: [
    GoRoute(path: AppRoutes.profile, builder: (_, _) => const ProfileScreen()),
    GoRoute(
      path: AppRoutes.schedule,
      builder: (_, _) => const Scaffold(body: Text('schedule stub')),
    ),
    GoRoute(
      path: AppRoutes.weeklyMissions,
      builder: (_, _) => const Scaffold(body: Text('missions stub')),
    ),
    GoRoute(path: AppRoutes.login, builder: (_, _) => const SizedBox()),
  ],
);

Future<GoRouter> _pumpProfile(
  WidgetTester tester, {
  required SessionUser? user,
  required _HistoryRepository history,
  required WeeklyMissions missions,
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final router = _router();
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        sessionControllerProvider.overrideWith(() => _FakeSession(user)),
        signedInProvider.overrideWithValue(user != null),
        historyRepositoryProvider.overrideWithValue(history),
        weeklyMissionsRepositoryProvider.overrideWithValue(
          _MissionsRepository(missions),
        ),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

AppLocalizations _l(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(ProfileScreen)));

void main() {
  testWidgets('a guest does not request history or missions', (tester) async {
    final history = _HistoryRepository([Ok(_history(const []))]);
    await _pumpProfile(
      tester,
      user: null,
      history: history,
      missions: _missions(),
    );

    expect(history.calls, 0);
    expect(find.byType(ProfileHistorySection), findsNothing);
    expect(find.byType(ProfileXpCard), findsNothing);
  });

  testWidgets('a signed-in user sees recent history and XP', (tester) async {
    final history = _HistoryRepository([
      Ok(
        _history([
          _entry(),
          _entry(
            slug: 'episode-2',
            title: 'Episode two',
            available: false,
            percent: 100,
          ),
        ]),
      ),
    ]);
    await _pumpProfile(
      tester,
      user: _user,
      history: history,
      missions: _missions(totalXp: 120, completed: 1),
    );
    final l = _l(tester);

    expect(find.text(l.profileXpTotal(120)), findsOneWidget);
    expect(find.text(l.profileMissionsDone(1)), findsOneWidget);
    expect(find.text('Episode one'), findsOneWidget);
    expect(find.text('Episode two'), findsOneWidget);
    expect(find.text(l.profileHistoryProgress('Series A', 7)), findsOneWidget);

    final available = find.ancestor(
      of: find.text('Episode one'),
      matching: find.byType(HistoryTile),
    );
    final unavailable = find.ancestor(
      of: find.text('Episode two'),
      matching: find.byType(HistoryTile),
    );
    expect(
      find.descendant(of: available, matching: find.byType(TextButton)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: unavailable, matching: find.byType(TextButton)),
      findsNothing,
    );
  });

  testWidgets('an empty history shows the empty state', (tester) async {
    await _pumpProfile(
      tester,
      user: _user,
      history: _HistoryRepository([Ok(_history(const []))]),
      missions: _missions(),
    );

    expect(find.text(_l(tester).profileRecentEmpty), findsOneWidget);
  });

  testWidgets('zero XP and no missions still show the XP card', (tester) async {
    await _pumpProfile(
      tester,
      user: _user,
      history: _HistoryRepository([Ok(_history(const []))]),
      missions: _missions(),
    );
    final l = _l(tester);

    expect(find.text(l.profileXpTotal(0)), findsOneWidget);
    expect(find.text(l.profileMissionsDone(0)), findsOneWidget);
  });

  testWidgets('a history error offers retry and reloads', (tester) async {
    final history = _HistoryRepository([
      Err(const NetworkException('offline')),
      Ok(_history([_entry(title: 'Loaded after retry')])),
    ]);
    await _pumpProfile(
      tester,
      user: _user,
      history: history,
      missions: _missions(),
    );
    final l = _l(tester);

    expect(find.text(l.catalogErrorNetwork), findsOneWidget);
    expect(history.calls, 1);

    await tester.tap(find.text(l.catalogRetry));
    await tester.pumpAndSettle();

    expect(history.calls, 2);
    expect(find.text('Loaded after retry'), findsOneWidget);
  });

  testWidgets('the bell opens the release schedule', (tester) async {
    final router = await _pumpProfile(
      tester,
      user: _user,
      history: _HistoryRepository([Ok(_history(const []))]),
      missions: _missions(),
    );

    await tester.tap(find.byTooltip(_l(tester).profileScheduleTooltip));
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      AppRoutes.schedule,
    );
  });

  testWidgets('the XP card opens weekly missions', (tester) async {
    final router = await _pumpProfile(
      tester,
      user: _user,
      history: _HistoryRepository([Ok(_history(const []))]),
      missions: _missions(totalXp: 120),
    );

    await tester.tap(find.text(_l(tester).profileXpTotal(120)));
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      AppRoutes.weeklyMissions,
    );
  });
}
