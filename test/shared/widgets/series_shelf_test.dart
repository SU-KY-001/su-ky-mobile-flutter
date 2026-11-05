import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:su_ky_mobile/app/theme/app_theme.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/domain/series.dart';
import 'package:su_ky_mobile/shared/widgets/series_shelf.dart';

SeriesSummary _series(String slug, {String title = 'Một chuỗi lịch sử dài'}) =>
    SeriesSummary(id: 'id-$slug', slug: slug, title: title, episodeCount: 12);

void main() {
  for (final scale in const [1.0, 1.15, 1.3, 1.5, 2.0]) {
    testWidgets('shelf lays out without overflow at text scale $scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: Scaffold(
            body: SeriesShelf(
              series: [
                _series('a'),
                _series('b', title: 'Tên rất dài'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
