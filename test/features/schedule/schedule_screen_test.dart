import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/app/theme/app_theme.dart';
import 'package:su_ky_mobile/core/error/result.dart';
import 'package:su_ky_mobile/features/schedule/data/schedule_providers.dart';
import 'package:su_ky_mobile/features/schedule/data/schedule_repository.dart';
import 'package:su_ky_mobile/features/schedule/domain/release.dart';
import 'package:su_ky_mobile/features/schedule/ui/release_tile.dart';
import 'package:su_ky_mobile/features/schedule/ui/schedule_screen.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

class _Repository implements ScheduleRepository {
  _Repository(this._onMonth);

  final List<Release> Function(DateTime month) _onMonth;
  final List<DateTime> calls = [];

  @override
  Future<Result<List<Release>>> month(DateTime monthStart) async {
    calls.add(monthStart);
    return Ok(_onMonth(monthStart));
  }
}

Release _release({
  String id = 'release-1',
  String title = 'Released episode',
  DateTime? scheduledAt,
  bool released = true,
}) => Release(
  id: id,
  title: title,
  scheduledAt: scheduledAt ?? DateTime.utc(2026, 1, 5, 9),
  released: released,
  episodeSlug: 'episode-slug',
  seriesTitle: 'Series title',
);

GoRouter _router() => GoRouter(
  initialLocation: AppRoutes.schedule,
  routes: [
    GoRoute(
      path: AppRoutes.schedule,
      builder: (_, _) => const ScheduleScreen(),
    ),
    GoRoute(path: AppRoutes.profile, builder: (_, _) => const SizedBox()),
  ],
);

Future<GoRouter> _pumpSchedule(
  WidgetTester tester,
  _Repository repository,
) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final router = _router();
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        scheduleRepositoryProvider.overrideWithValue(repository),
        scheduleClockProvider.overrideWithValue(() => DateTime(2026, 1, 15)),
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
    AppLocalizations.of(tester.element(find.byType(ScheduleScreen)));

void main() {
  testWidgets('an empty month shows the empty state', (tester) async {
    final repository = _Repository((_) => []);
    await _pumpSchedule(tester, repository);
    final l = _l(tester);

    expect(find.text(l.scheduleEmpty), findsOneWidget);
    expect(find.text(l.scheduleMonth(DateTime(2026, 1))), findsOneWidget);
    expect(repository.calls, [DateTime(2026, 1)]);
  });

  testWidgets('releases show status labels and only released ones play', (
    tester,
  ) async {
    final repository = _Repository(
      (_) => [
        _release(),
        _release(
          id: 'release-2',
          title: 'Upcoming episode',
          scheduledAt: DateTime.utc(2026, 1, 20, 9),
          released: false,
        ),
      ],
    );
    await _pumpSchedule(tester, repository);
    final l = _l(tester);

    expect(find.text('Released episode'), findsOneWidget);
    expect(find.text('Upcoming episode'), findsOneWidget);
    expect(find.text(l.scheduleReleased), findsOneWidget);
    expect(find.text(l.scheduleUpcoming), findsOneWidget);

    final releasedTile = find.ancestor(
      of: find.text('Released episode'),
      matching: find.byType(ReleaseTile),
    );
    final upcomingTile = find.ancestor(
      of: find.text('Upcoming episode'),
      matching: find.byType(ReleaseTile),
    );
    expect(
      find.descendant(of: releasedTile, matching: find.byType(RoundPlay)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: upcomingTile, matching: find.byType(RoundPlay)),
      findsNothing,
    );
  });

  testWidgets('changing month requests the new month', (tester) async {
    final repository = _Repository((_) => []);
    await _pumpSchedule(tester, repository);
    final l = _l(tester);

    await tester.tap(find.byTooltip(l.scheduleNextMonth));
    await tester.pumpAndSettle();

    expect(repository.calls.last, DateTime(2026, 2));
    expect(find.text(l.scheduleMonth(DateTime(2026, 2))), findsOneWidget);

    await tester.tap(find.byTooltip(l.schedulePrevMonth));
    await tester.pumpAndSettle();

    expect(repository.calls.last, DateTime(2026, 1));
  });
}
