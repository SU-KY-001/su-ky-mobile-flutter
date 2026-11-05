import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/app/theme/app_theme.dart';
import 'package:su_ky_mobile/core/di/app_retry.dart';
import 'package:su_ky_mobile/core/error/app_exception.dart';
import 'package:su_ky_mobile/core/error/result.dart';
import 'package:su_ky_mobile/features/home/ui/home_events_section.dart';
import 'package:su_ky_mobile/features/home/ui/home_periods_section.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_repository.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode_detail.dart';
import 'package:su_ky_mobile/shared/catalog/domain/historical_event.dart';
import 'package:su_ky_mobile/shared/catalog/domain/historical_period.dart';
import 'package:su_ky_mobile/shared/catalog/domain/paged.dart';
import 'package:su_ky_mobile/shared/catalog/domain/series.dart';
import 'package:su_ky_mobile/shared/timeline/timeline_period.dart';

const _scrollGap = 3000.0;

HistoricalEvent _event(String slug) => HistoricalEvent(
  id: 'id-$slug',
  slug: slug,
  name: 'Sự kiện $slug',
  summary: 'Tóm tắt $slug',
  timeLabel: '938',
  periodName: 'Thời kỳ X',
  phaseName: 'Giai đoạn Y',
  citations: const [],
);

class _Repo implements CatalogRepository {
  final eventCalls = <String?>[];
  Result<List<HistoricalEvent>> Function(String? periodId) onEvents = (_) =>
      Ok([
        for (final s in ['a', 'b', 'c', 'd']) _event(s),
      ]);
  Result<List<HistoricalPeriod>> periodsResult = const Ok([
    HistoricalPeriod(id: 'p1', slug: 'p1', name: 'Thời Lý'),
    HistoricalPeriod(id: 'p2', slug: 'p2', name: 'Thời Trần'),
  ]);

  @override
  Future<Result<List<HistoricalEvent>>> events({String? periodId}) async {
    eventCalls.add(periodId);
    return onEvents(periodId);
  }

  @override
  Future<Result<List<HistoricalPeriod>>> periods() async => periodsResult;

  @override
  Future<Result<HistoricalEvent>> eventDetail(String slug) =>
      throw UnimplementedError();
  @override
  Future<Result<Paged<SeriesSummary>>> listSeries({
    int page = 1,
    int limit = 20,
    String? query,
    String? periodId,
    String? eventId,
  }) => throw UnimplementedError();
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

/// Hosts [child] after a tall spacer, in a ListView like the real Home, so
/// the primary scroll controller exists and can be scrolled away from 0.
Future<GoRouter> _pump(WidgetTester tester, _Repo repo, Widget child) async {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => Scaffold(
          body: ListView(
            children: [
              const SizedBox(height: _scrollGap),
              child,
            ],
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.event,
        builder: (_, state) => Text('event ${state.pathParameters['slug']}'),
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (_, _) => const Text('history tab'),
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

String _location(GoRouter r) =>
    r.routerDelegate.currentConfiguration.last.matchedLocation;

Future<void> _scrollToSection(WidgetTester tester) async {
  final position = tester
      .state<ScrollableState>(find.byType(Scrollable).first)
      .position;
  position.jumpTo(position.maxScrollExtent);
  await tester.pumpAndSettle();
}

void main() {
  group('HomeEventsSection', () {
    testWidgets('shows at most three cards; tapping one opens its event', (
      tester,
    ) async {
      final router = await _pump(tester, _Repo(), const HomeEventsSection());
      await _scrollToSection(tester);
      expect(find.text('Sự kiện a'), findsOneWidget);
      expect(find.text('Sự kiện c'), findsOneWidget);
      expect(find.text('Sự kiện d'), findsNothing);

      await tester.tap(find.text('Sự kiện b'));
      await tester.pumpAndSettle();
      expect(_location(router), '/events/b');
    });

    testWidgets('"View all" opens the history tab route', (tester) async {
      final router = await _pump(tester, _Repo(), const HomeEventsSection());
      await _scrollToSection(tester);
      await tester.tap(find.text(_l(tester).viewAll));
      await tester.pumpAndSettle();
      expect(_location(router), AppRoutes.history);
    });

    testWidgets('an empty list shows the empty message', (tester) async {
      final repo = _Repo()..onEvents = (_) => const Ok([]);
      await _pump(tester, repo, const HomeEventsSection());
      await _scrollToSection(tester);
      expect(find.text(_l(tester).homeEventsEmpty), findsOneWidget);
    });

    testWidgets('an error offers retry that reloads', (tester) async {
      final repo = _Repo()
        ..onEvents = (_) => const Err(ApiException('x', statusCode: 500));
      await _pump(tester, repo, const HomeEventsSection());
      await _scrollToSection(tester);
      final retry = find.text(_l(tester).catalogRetry);
      expect(retry, findsOneWidget);

      repo.onEvents = (_) => Ok([_event('a')]);
      await tester.tap(retry);
      await tester.pumpAndSettle();
      expect(find.text('Sự kiện a'), findsOneWidget);
    });
  });

  group('HomePeriodsSection', () {
    testWidgets('lists every period; tapping one selects it and opens the '
        'timeline tab', (tester) async {
      final router = await _pump(tester, _Repo(), const HomePeriodsSection());
      await _scrollToSection(tester);
      expect(find.text('Thời Lý'), findsOneWidget);
      expect(find.byIcon(Symbols.chevron_right), findsNWidgets(2));

      final container = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold)),
      );
      await tester.tap(find.text('Thời Trần'));
      await tester.pumpAndSettle();

      expect(container.read(timelineViewModelProvider), 'p2');
      expect(_location(router), AppRoutes.history);
    });

    testWidgets('renders nothing when there are no periods', (tester) async {
      final repo = _Repo()..periodsResult = const Ok([]);
      await _pump(tester, repo, const HomePeriodsSection());
      expect(find.text(_l(tester).homePeriodsTitle), findsNothing);
    });

    testWidgets('renders nothing when loading the periods failed', (
      tester,
    ) async {
      final repo = _Repo()
        ..periodsResult = const Err(ApiException('x', statusCode: 500));
      await _pump(tester, repo, const HomePeriodsSection());
      expect(find.text(_l(tester).homePeriodsTitle), findsNothing);
    });
  });
}
