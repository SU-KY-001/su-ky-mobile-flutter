import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/features/home/ui/home_mission_row.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/missions/domain/weekly_missions.dart';
import 'package:su_ky_mobile/shared/missions/missions_providers.dart';

WeeklyMission _mission(String id, MissionStatus status) => WeeklyMission(
  id: id,
  title: id,
  activity: MissionActivity.completeEpisode,
  targetCount: 3,
  progressCount: status == MissionStatus.completed ? 3 : 1,
  xpReward: 50,
  status: status,
);

Future<GoRouter> _pump(WidgetTester tester, WeeklyMissions? missions) async {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: HomeMissionRow()),
      ),
      GoRoute(
        path: AppRoutes.weeklyMissions,
        builder: (_, _) => const Scaffold(),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [weeklyMissionsProvider.overrideWith((_) async => missions)],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('vi'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('shows completed/total and opens missions on tap', (
    tester,
  ) async {
    final router = await _pump(
      tester,
      WeeklyMissions(
        totalXp: 50,
        weekEnd: DateTime.utc(2026, 11, 9),
        items: [
          _mission('a', MissionStatus.completed),
          _mission('b', MissionStatus.inProgress),
        ],
      ),
    );

    expect(find.text('1/2'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    await tester.tap(find.byType(HomeMissionRow));
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      AppRoutes.weeklyMissions,
    );
  });

  testWidgets('is hidden for guests (null missions)', (tester) async {
    await _pump(tester, null);

    expect(find.byType(LinearProgressIndicator), findsNothing);
  });
}
