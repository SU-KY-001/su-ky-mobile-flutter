import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:su_ky_mobile/app/app.dart';
import 'package:su_ky_mobile/app/theme/app_theme.dart';
import 'package:su_ky_mobile/features/auth/ui/login_screen.dart';
import 'package:su_ky_mobile/features/home/ui/home_screen.dart';
import 'package:su_ky_mobile/features/player/ui/player_screen.dart';
import 'package:su_ky_mobile/features/search/ui/search_screen.dart';
import 'package:su_ky_mobile/features/series/ui/series_screen.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/widgets/series_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('Inter')
          ..addFont(
            rootBundle.load('assets/fonts/Inter/static/Inter_18pt-Regular.ttf'),
          )
          ..addFont(
            rootBundle.load('assets/fonts/Inter/static/Inter_18pt-Medium.ttf'),
          )
          ..addFont(
            rootBundle.load(
              'assets/fonts/Inter/static/Inter_18pt-SemiBold.ttf',
            ),
          )
          ..addFont(
            rootBundle.load('assets/fonts/Inter/static/Inter_18pt-Bold.ttf'),
          )
          ..addFont(
            rootBundle.load(
              'assets/fonts/Inter/static/Inter_18pt-ExtraBold.ttf',
            ),
          )
          ..addFont(
            rootBundle.load('assets/fonts/Inter/static/Inter_18pt-Italic.ttf'),
          ))
        .load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  void noop() {}
  testWidgets(
    'navigation connects discovery, series, player, search and login',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const ProviderScope(child: App()));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(SeriesCard).first);
      await tester.tap(find.byType(SeriesCard).first);
      await tester.pumpAndSettle();
      expect(find.text('Chi tiết Series'), findsOneWidget);
      await tester.tap(find.text('Nghe từ đầu'));
      await tester.pumpAndSettle();
      expect(find.text('Bạch Đằng 938 Giang Sơn'), findsOneWidget);
      await tester.tap(find.byTooltip('Đóng'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Quay lại'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tìm kiếm'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'khong-co-noi-dung');
      await tester.pump();
      expect(
        find.text('Không tìm thấy nội dung. Thử từ khóa khác nhé.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Cá nhân'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Đăng nhập & Tiếp tục nghe'));
      await tester.tap(find.text('Đăng nhập & Tiếp tục nghe'));
      await tester.pumpAndSettle();
      expect(
        find.text('Nhập email hợp lệ và mật khẩu tối thiểu 6 ký tự.'),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );
  final screens = <String, Widget>{
    'home': HomeScreen(
      onSearch: noop,
      onSeries: noop,
      onPlayer: noop,
      onProfile: noop,
    ),
    'login': LoginScreen(onClose: noop, onContinue: noop),
    'search': SearchScreen(
      onHome: noop,
      onProfile: noop,
      onSeries: noop,
      onPlayer: noop,
    ),
    'series': SeriesScreen(onBack: noop, onPlayer: noop),
    'player': PlayerScreen(onBack: noop, onSeries: noop),
  };
  for (final size in [const Size(390, 844), const Size(320, 640)]) {
    for (final entry in screens.entries) {
      testWidgets('${entry.key} renders without overflow at ${size.width}', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final key = GlobalKey();
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.light,
              locale: const Locale('vi'),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: RepaintBoundary(key: key, child: entry.value),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final context = key.currentContext!;
          for (final asset in [
            'assets/images/bach_dang.jpg',
            'assets/images/dong_a.jpg',
            'assets/images/dam_da.jpg',
            'assets/images/me_linh.jpg',
            'assets/images/thang_long.jpg',
          ]) {
            await precacheImage(AssetImage(asset), context);
          }
        });
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (const bool.fromEnvironment('CAPTURE_UI') && size.width == 390) {
          await tester.runAsync(() async {
            final boundary =
                key.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final image = await boundary.toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final directory = Directory('build/ui_previews');
            await directory.create(recursive: true);
            await File('${directory.path}/${entry.key}.png')
                .writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
