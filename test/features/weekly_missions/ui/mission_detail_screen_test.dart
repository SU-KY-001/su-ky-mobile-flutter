import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/app.dart';
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
  void noop() {}
  for (final locale in ['vi', 'en']) {
    for (final width in [320.0, 390.0, 1440.0]) {
      for (final honours in [false, true]) {
        final name = honours ? 'honours' : 'mission_detail';
        testWidgets('$name renders and scrolls at $width in $locale', (
          tester,
        ) async {
          await tester.binding.setSurfaceSize(Size(width, 844));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          var continued = false;
          final key = GlobalKey();
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp(
                theme: AppTheme.light,
                locale: Locale(locale),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: RepaintBoundary(
                  key: key,
                  child: honours
                      ? HonoursScreen(
                          onBack: noop,
                          onDiscover: () => continued = true,
                          onProfile: noop,
                        )
                      : MissionDetailScreen(
                          onBack: noop,
                          onHonours: noop,
                          onProfile: noop,
                          onListen: () => continued = true,
                        ),
                ),
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
          await tester.tap(
            find.text(honours ? l.honoursDiscover : l.missionContinue),
          );
          await tester.pumpAndSettle();
          expect(continued, isTrue);
          if (honours) {
            await tester.tap(find.text(l.honoursCollection));
            await tester.pumpAndSettle();
            expect(find.byType(BottomSheet), findsOneWidget);
            expect(
              find.text(l.honoursBadgeTitle).hitTestable(),
              findsOneWidget,
            );
            expect(tester.takeException(), isNull);
          }
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
      await tester.tap(find.text('Nhiệm vụ tuần'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Hành trình chưa dừng lại'),
        300,
      );
      await tester.ensureVisible(find.text('Hành trình chưa dừng lại'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hành trình chưa dừng lại'));
      await tester.pumpAndSettle();
      expect(find.byType(MissionDetailScreen), findsOneWidget);
      await tester.tap(find.text('Tiếp tục nhiệm vụ'));
      await tester.pumpAndSettle();
      expect(find.byType(PlayerScreen), findsOneWidget);
      expect(container.read(audioViewModelProvider).episode, 2);
      expect(container.read(audioViewModelProvider).playing, isTrue);
      GoRouter.of(tester.element(find.byType(PlayerScreen))).pop();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Bảng Vinh Danh'));
      await tester.pumpAndSettle();
      expect(find.byType(HonoursScreen), findsOneWidget);
      await tester.tap(find.byTooltip('Chia sẻ'));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
      await tester.tap(find.text('Quay về Khám phá'));
      await tester.pumpAndSettle();
      expect(find.text('Lắng nghe tiền nhân'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      container.dispose();
    },
  );
}
