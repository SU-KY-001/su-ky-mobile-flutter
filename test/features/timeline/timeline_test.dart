import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/app/theme/app_theme.dart';
import 'package:su_ky_mobile/core/di/app_retry.dart';
import 'package:su_ky_mobile/core/error/app_exception.dart';
import 'package:su_ky_mobile/core/error/result.dart';
import 'package:su_ky_mobile/features/timeline/ui/event_detail_screen.dart';
import 'package:su_ky_mobile/features/timeline/ui/timeline_screen.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_repository.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode_detail.dart';
import 'package:su_ky_mobile/shared/catalog/domain/historical_event.dart';
import 'package:su_ky_mobile/shared/catalog/domain/historical_period.dart';
import 'package:su_ky_mobile/shared/catalog/domain/paged.dart';
import 'package:su_ky_mobile/shared/catalog/domain/series.dart';
import 'package:su_ky_mobile/shared/timeline/timeline_period.dart';

HistoricalEvent _event(
  String slug, {
  String label = 'Khoảng 500 TCN - Khoảng 111 TCN',
  List<EventCitation> citations = const [],
}) => HistoricalEvent(
  id: 'id-$slug',
  slug: slug,
  name: 'Sự kiện $slug',
  summary: 'Tóm tắt $slug',
  timeLabel: label,
  periodName: 'Thời kỳ X',
  phaseName: 'Giai đoạn Y',
  citations: citations,
);

SeriesSummary _series(String slug) => SeriesSummary(
  id: 'sid-$slug',
  slug: slug,
  title: 'Podcast $slug',
  episodeCount: 3,
);

class _Repo implements CatalogRepository {
  final eventCalls = <String?>[];
  Result<List<HistoricalEvent>> Function(String? periodId) onEvents = (_) =>
      Ok([_event('a'), _event('b', label: '938')]);
  Result<HistoricalEvent> Function(String slug) onDetail = (slug) =>
      Ok(_event(slug));
  Result<Paged<SeriesSummary>> Function() onSeries = () =>
      const Ok(Paged(items: [], page: 1, limit: 20, total: 0));
  var periods0 = const [
    HistoricalPeriod(id: 'p1', slug: 'p1', name: 'Thời Lý'),
  ];

  @override
  Future<Result<List<HistoricalEvent>>> events({String? periodId}) async {
    eventCalls.add(periodId);
    return onEvents(periodId);
  }

  @override
  Future<Result<HistoricalEvent>> eventDetail(String slug) async =>
      onDetail(slug);

  @override
  Future<Result<List<HistoricalPeriod>>> periods() async => Ok(periods0);

  @override
  Future<Result<Paged<SeriesSummary>>> listSeries({
    int page = 1,
    int limit = 20,
    String? query,
    String? periodId,
    String? eventId,
  }) async => onSeries();

  @override
  Future<Result<SeriesDetail>> seriesDetail(String slug) =>
      throw UnimplementedError();
  @override
  Future<Result<EpisodeDetail>> episodeDetail(String slug) =>
      throw UnimplementedError();
  @override
  Future<Result<List<LatestEpisode>>> latestEpisodes() =>
      throw UnimplementedError();
}

Future<GoRouter> _pump(
  WidgetTester tester,
  _Repo repo, {
  String start = '/',
}) async {
  final router = GoRouter(
    initialLocation: start,
    routes: [
      GoRoute(path: '/', builder: (_, _) => const TimelineScreen()),
      GoRoute(
        path: AppRoutes.event,
        builder: (_, state) =>
            EventDetailScreen(slug: state.pathParameters['slug']!),
      ),
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
      overrides: [catalogRepositoryProvider.overrideWithValue(repo)],
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

AppLocalizations _l(WidgetTester t) =>
    AppLocalizations.of(t.element(find.byType(Scaffold).first));

void main() {
  test('the selection starts at "all" and can be changed and cleared', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final sub = c.listen(timelineViewModelProvider, (_, _) {});
    expect(sub.read(), isNull);
    c.read(timelineViewModelProvider.notifier).select('p1');
    expect(sub.read(), 'p1');
    c.read(timelineViewModelProvider.notifier).select(null);
    expect(sub.read(), isNull);
  });

  group('TimelineScreen', () {
    testWidgets('lists every event with its server time label', (tester) async {
      await _pump(tester, _Repo());
      expect(find.text('Sự kiện a'), findsOneWidget);
      expect(find.text('Sự kiện b'), findsOneWidget);
      expect(find.text('938'), findsOneWidget);
      expect(
        find.text('500 TCN - 111 TCN'),
        findsOneWidget,
        reason: 'axis drops the "Khoảng " prefix',
      );
    });

    testWidgets('choosing a period asks the repo for that period', (
      tester,
    ) async {
      final repo = _Repo();
      await _pump(tester, repo);
      expect(repo.eventCalls, [null]);
      await tester.tap(find.text('Thời Lý'));
      await tester.pumpAndSettle();
      expect(repo.eventCalls, [null, 'p1']);
    });

    testWidgets('an empty period shows the empty state', (tester) async {
      final repo = _Repo()..onEvents = (_) => const Ok([]);
      await _pump(tester, repo);
      expect(find.text(_l(tester).timelineEmptyTitle), findsOneWidget);
    });

    testWidgets('an error offers retry that reloads', (tester) async {
      final repo = _Repo()
        ..onEvents = (_) => const Err(ApiException('x', statusCode: 500));
      await _pump(tester, repo);
      final retry = find.text(_l(tester).catalogRetry);
      expect(retry, findsOneWidget);
      repo.onEvents = (_) => Ok([_event('a')]);
      await tester.tap(retry);
      await tester.pumpAndSettle();
      expect(find.text('Sự kiện a'), findsOneWidget);
    });

    testWidgets('tapping an event opens its detail route', (tester) async {
      final router = await _pump(tester, _Repo());
      await tester.tap(find.text('Sự kiện a'));
      await tester.pumpAndSettle();
      expect(
        router.routerDelegate.currentConfiguration.last.matchedLocation,
        '/events/a',
      );
    });
  });

  group('EventDetailScreen', () {
    const citation = EventCitation(
      locator: 'tr. 12',
      sourceTitle: 'Đại Việt sử ký',
    );

    testWidgets('shows breadcrumb, sources and the fallback author', (
      tester,
    ) async {
      final repo = _Repo()
        ..onDetail = (slug) => Ok(_event(slug, citations: [citation]));
      await _pump(tester, repo, start: '/events/a');
      final l = _l(tester);
      expect(find.text('Sự kiện a'), findsWidgets);
      expect(
        find.text(l.eventBreadcrumb('Thời kỳ X', 'Giai đoạn Y')),
        findsOneWidget,
      );
      expect(find.text(l.eventSourcesTitle), findsOneWidget);
      expect(find.text('Đại Việt sử ký'), findsOneWidget);
      expect(
        find.text(l.eventSourceLine(l.eventSourceFallbackAuthor, 'tr. 12')),
        findsOneWidget,
      );
    });

    testWidgets('no citations and no linked series hide both sections', (
      tester,
    ) async {
      await _pump(tester, _Repo(), start: '/events/a');
      final l = _l(tester);
      expect(find.text(l.eventSourcesTitle), findsNothing);
      expect(find.text(l.eventRelatedTitle), findsNothing);
    });

    testWidgets('linked series are listed and open the series route', (
      tester,
    ) async {
      final repo = _Repo()
        ..onSeries = () =>
            Ok(Paged(items: [_series('s1')], page: 1, limit: 20, total: 1));
      final router = await _pump(tester, repo, start: '/events/a');
      expect(find.text(_l(tester).eventRelatedTitle), findsOneWidget);
      await tester.tap(find.text('Podcast s1'));
      await tester.pumpAndSettle();
      expect(
        router.routerDelegate.currentConfiguration.last.matchedLocation,
        '/series/s1',
      );
    });

    testWidgets('a failing related-series request does not break the page', (
      tester,
    ) async {
      final repo = _Repo()
        ..onSeries = () => const Err(ApiException('x', statusCode: 500));
      await _pump(tester, repo, start: '/events/a');
      expect(find.text('Sự kiện a'), findsWidgets);
      expect(find.text(_l(tester).eventRelatedTitle), findsNothing);
    });

    testWidgets('an unknown slug shows an error with retry', (tester) async {
      final repo = _Repo()
        ..onDetail = (_) => const Err(ApiException('x', statusCode: 404));
      await _pump(tester, repo, start: '/events/missing');
      expect(find.text(_l(tester).catalogRetry), findsOneWidget);
    });
  });
}
