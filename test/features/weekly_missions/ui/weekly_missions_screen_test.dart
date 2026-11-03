import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/app/theme/app_theme.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_missions_screen.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

GoRouter _router() => GoRouter(
  initialLocation: AppRoutes.weeklyMissions,
  routes: [
    GoRoute(
      path: AppRoutes.weeklyMissions,
      builder: (_, _) => const WeeklyMissionsScreen(),
    ),
    for (final path in [AppRoutes.home, AppRoutes.search, AppRoutes.login])
      GoRoute(path: path, builder: (_, _) => const SizedBox()),
  ],
);

void main() {
  for (final locale in ['vi', 'en']) {
    for (final width in [320.0, 390.0, 1440.0]) {
      testWidgets('weekly missions fits and navigates at $width in $locale', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(Size(width, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final router = _router();
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp.router(
              theme: AppTheme.light,
              locale: Locale(locale),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: router,
            ),
          ),
        );
        await tester.pumpAndSettle();
        final l = AppLocalizations.of(tester.element(find.byType(ListView)));
        final content = find.byType(ListView);
        final bounds = tester.getRect(content);
        expect(
          bounds.width,
          width < AppDesign.maxWidth ? width : AppDesign.maxWidth,
        );
        expect(bounds.center.dx, width / 2);
        expect(find.byType(MainNavigation), findsOneWidget);
        expect(tester.takeException(), isNull);
        for (var step = 0; step < 6; step++) {
          await tester.drag(content, const Offset(0, -400));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        expect(find.text(l.missionsQuoteSource).hitTestable(), findsOneWidget);
        for (final entry in {
          l.discover: AppRoutes.home,
          l.search: AppRoutes.search,
          l.profile: AppRoutes.login,
        }.entries) {
          router.go(AppRoutes.weeklyMissions);
          await tester.pumpAndSettle();
          await tester.tap(find.text(entry.key));
          await tester.pumpAndSettle();
          expect(
            router.routerDelegate.currentConfiguration.last.matchedLocation,
            entry.value,
          );
        }
      });
    }
  }

  testWidgets('tapping a pending mission completes it via the sheet', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: AppTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: _router(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final l = AppLocalizations.of(tester.element(find.byType(ListView)));
    final streak = find.text(l.missionsStreakTitle);
    await tester.scrollUntilVisible(streak, 300);
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.tap(streak);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.missionsTryComplete));
    await tester.pumpAndSettle();
    expect(find.text(l.missionsDemoDone), findsOneWidget);
    final count = find.text(l.missionsProgressCount(4, 5));
    await tester.scrollUntilVisible(count, -300);
    expect(count, findsOneWidget);
  });
}
