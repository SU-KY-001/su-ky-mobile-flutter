import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/app.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/app/theme/app_theme.dart';
import 'package:su_ky_mobile/features/player/ui/player_screen.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/honours_screen.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/mission_detail_screen.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/audio_view_model.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('Inter')
          ..addFont(
            rootBundle.load('assets/fonts/Inter/static/Inter_18pt-Regular.ttf'),
          )
          ..addFont(
            rootBundle.load('assets/fonts/Inter/static/Inter_18pt-Bold.ttf'),
          ))
        .load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  for (final locale in ['vi', 'en']) {
    for (final width in [320.0, 390.0, 1440.0]) {
      for (final honours in [false, true]) {
        final name = honours ? 'honours' : 'mission_detail';
        testWidgets('$name renders and scrolls at $width in $locale', (
          tester,
        ) async {
          await tester.binding.setSurfaceSize(Size(width, 844));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final key = GlobalKey();
          final router = GoRouter(
            initialLocation: '/start',
            routes: [
              GoRoute(
                path: '/start',
                builder: (_, _) => RepaintBoundary(
                  key: key,
                  child: honours
                      ? const HonoursScreen()
                      : const MissionDetailScreen(),
                ),
              ),
              GoRoute(
                path: AppRoutes.home,
                builder: (_, _) => const SizedBox(),
              ),
              GoRoute(
                path: AppRoutes.player,
                builder: (_, _) => const SizedBox(),
              ),
            ],
          );
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
          expect(tester.takeException(), isNull);
          final bounds = tester.getRect(find.byType(ListView));
          expect(bounds.width, width.clamp(0, AppDesign.maxWidth));
          expect(bounds.center.dx, width / 2);
          if (const bool.fromEnvironment('CAPTURE_UI') &&
              width == 390 &&
              locale == 'vi') {
            await tester.runAsync(() async {
              final boundary =
                  key.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary;
              final image = await boundary.toImage();
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              await Directory('build/ui_previews').create(recursive: true);
              await File('build/ui_previews/$name.png')
                  .writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
          for (var i = 0; i < 7; i++) {
            await tester.drag(find.byType(ListView), const Offset(0, -350));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }
          final l = AppLocalizations.of(tester.element(find.byType(ListView)));
          expect(
            find.text(l.missionSampleNotice).hitTestable(),
            findsOneWidget,
          );
          if (honours) {
            await tester.tap(find.text(l.honoursCollection));
            await tester.pumpAndSettle();
            expect(find.byType(BottomSheet), findsOneWidget);
            expect(
              find.text(l.honoursBadgeTitle).hitTestable(),
              findsOneWidget,
            );
            expect(tester.takeException(), isNull);
            Navigator.of(tester.element(find.byType(BottomSheet))).pop();
            await tester.pumpAndSettle();
          }
          await tester.tap(
            find.text(honours ? l.honoursDiscover : l.missionContinue),
          );
          await tester.pumpAndSettle();
          final expected = honours ? AppRoutes.home : AppRoutes.player;
          expect(
            router.routerDelegate.currentConfiguration.last.matchedLocation,
            expected,
          );
          await tester.pumpWidget(const SizedBox());
        });
      }
    }
  }

  testWidgets(
    'weekly missions opens detail, recommended player and honour board',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final container = ProviderContainer();
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const App()),
      );
      await tester.pumpAndSettle();
      final l = AppLocalizations.of(
        tester.element(find.byType(Scaffold).first),
      );
      await tester.tap(find.text(l.weeklyMissions));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text(l.missionsJourneyTitle), 300);
      await tester.ensureVisible(find.text(l.missionsJourneyTitle));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.missionsJourneyTitle));
      await tester.pumpAndSettle();
      expect(find.byType(MissionDetailScreen), findsOneWidget);
      await tester.tap(find.text(l.missionContinue));
      await tester.pumpAndSettle();
      expect(find.byType(PlayerScreen), findsOneWidget);
      expect(container.read(audioViewModelProvider).episode, 2);
      expect(container.read(audioViewModelProvider).playing, isTrue);
      GoRouter.of(tester.element(find.byType(PlayerScreen))).pop();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(l.honoursTitle));
      await tester.pumpAndSettle();
      expect(find.byType(HonoursScreen), findsOneWidget);
      await tester.tap(find.byTooltip(l.share));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
      await tester.tap(find.text(l.honoursDiscover));
      await tester.pumpAndSettle();
      expect(find.text(l.homeHeading), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      container.dispose();
    },
  );
}
