import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:su_ky_mobile/app/theme/app_theme.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_missions_screen.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

void main() {
  for (final width in [320.0, 390.0, 1440.0]) {
    testWidgets('weekly missions fits and scrolls at $width', (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var homeOpened = false;
      var searchOpened = false;
      var profileOpened = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: WeeklyMissionsScreen(
            onHome: () => homeOpened = true,
            onSearch: () => searchOpened = true,
            onProfile: () => profileOpened = true,
          ),
        ),
      );
      await tester.pumpAndSettle();
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
      expect(
        find.text('— ĐẠI VIỆT SỬ KÝ TOÀN THƯ').hitTestable(),
        findsOneWidget,
      );
      await tester.tap(find.text('Khám phá'));
      await tester.pumpAndSettle();
      expect(homeOpened, isTrue);
      await tester.tap(find.text('Tìm kiếm'));
      await tester.pumpAndSettle();
      expect(searchOpened, isTrue);
      await tester.tap(find.text('Cá nhân'));
      await tester.pumpAndSettle();
      expect(profileOpened, isTrue);
    });
  }
}
