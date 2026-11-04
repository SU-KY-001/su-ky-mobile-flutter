import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/theme/app_theme.dart';
import 'package:su_ky_mobile/core/di/app_retry.dart';
import 'package:su_ky_mobile/core/error/result.dart';
import 'package:su_ky_mobile/features/podcast/ui/podcast_screen.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_repository.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode_detail.dart';
import 'package:su_ky_mobile/shared/catalog/domain/historical_event.dart';
import 'package:su_ky_mobile/shared/catalog/domain/historical_period.dart';
import 'package:su_ky_mobile/shared/catalog/domain/paged.dart';
import 'package:su_ky_mobile/shared/catalog/domain/series.dart';

SeriesSummary _series(String slug) => SeriesSummary(
  id: 'id-$slug',
  slug: slug,
  title: 'Series $slug',
  description: 'Mô tả không được hiện $slug',
  episodeCount: 4,
);

class _Repo implements CatalogRepository {
  @override
  Future<Result<Paged<SeriesSummary>>> listSeries({
    int page = 1,
    int limit = 20,
    String? query,
    String? periodId,
    String? eventId,
  }) async => Ok(
    Paged(items: [_series('a'), _series('b')], page: 1, limit: 20, total: 2),
  );

  @override
  Future<Result<List<LatestEpisode>>> latestEpisodes() async => Ok([
    LatestEpisode(
      seriesSlug: 'a',
      seriesTitle: 'Series a',
      episode: EpisodeSummary(
        id: 'e1',
        slug: 'e1',
        title: 'Tập mới nhất',
        sortOrder: 1,
        publishedAt: DateTime(2026, 11, 3),
        narrations: const [
          Narration(
            id: 'n1',
            type: NarrationType.firstPerson,
            available: true,
            durationMs: 125000,
          ),
        ],
      ),
    ),
  ]);

  @override
  Future<Result<SeriesDetail>> seriesDetail(String slug) =>
      throw UnimplementedError();
  @override
  Future<Result<EpisodeDetail>> episodeDetail(String slug) =>
      throw UnimplementedError();
  @override
  Future<Result<List<HistoricalEvent>>> events({String? periodId}) =>
      throw UnimplementedError();
  @override
  Future<Result<HistoricalEvent>> eventDetail(String slug) =>
      throw UnimplementedError();
  @override
  Future<Result<List<HistoricalPeriod>>> periods() =>
      throw UnimplementedError();
}

Future<GoRouter> _pump(WidgetTester tester) async {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const PodcastScreen()),
      GoRoute(
        path: '/series/:slug',
        builder: (_, state) => Text('series ${state.pathParameters['slug']}'),
      ),
    ],
  );
  addTearDown(router.dispose);
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      retry: appRetry,
      overrides: [catalogRepositoryProvider.overrideWithValue(_Repo())],
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

void main() {
  testWidgets('shows hero, series shelf with counts and no descriptions', (
    tester,
  ) async {
    await _pump(tester);
    final l = AppLocalizations.of(tester.element(find.byType(Scaffold).first));
    expect(find.text(l.podcastTitle), findsOneWidget);
    expect(find.text('Series a'), findsNWidgets(2), reason: 'hero + shelf');
    expect(find.text('Series b'), findsOneWidget);
    expect(find.text(l.seriesEpisodeCount(4)), findsNWidgets(2));
    expect(find.textContaining('Mô tả không được hiện'), findsNothing);
  });

  testWidgets('latest episodes are rows with series, date and duration', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.text('Tập mới nhất'), findsOneWidget);
    expect(find.textContaining('Series a · 11/3/2026 · 2:05'), findsOneWidget);
  });

  testWidgets('tapping a shelf item opens the series route', (tester) async {
    final router = await _pump(tester);
    await tester.tap(find.text('Series b'));
    await tester.pumpAndSettle();
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      '/series/b',
    );
  });
}
