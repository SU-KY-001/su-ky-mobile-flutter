import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/app/theme/app_theme.dart';
import 'package:su_ky_mobile/core/di/app_retry.dart';
import 'package:su_ky_mobile/core/error/result.dart';
import 'package:su_ky_mobile/features/series/ui/episode_list_tile.dart';
import 'package:su_ky_mobile/features/series/ui/series_screen.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_repository.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode_detail.dart';
import 'package:su_ky_mobile/shared/catalog/domain/historical_event.dart';
import 'package:su_ky_mobile/shared/catalog/domain/historical_period.dart';
import 'package:su_ky_mobile/shared/catalog/domain/paged.dart';
import 'package:su_ky_mobile/shared/catalog/domain/series.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

const _longDescription =
    'Mô tả rất dài về series lịch sử này. Mô tả rất dài về series lịch sử '
    'này. Mô tả rất dài về series lịch sử này. Mô tả rất dài về series lịch '
    'sử này. Mô tả rất dài về series lịch sử này. Mô tả rất dài về series '
    'lịch sử này. Mô tả rất dài về series lịch sử này.';

EpisodeSummary _episode(String slug, {bool audio = true}) => EpisodeSummary(
  id: 'id-$slug',
  slug: slug,
  title: 'Tập $slug',
  sortOrder: 1,
  description: 'Giới thiệu $slug',
  narrations: [
    Narration(
      id: 'n-$slug',
      type: NarrationType.firstPerson,
      available: audio,
      durationMs: 35000,
    ),
  ],
);

class _Repo implements CatalogRepository {
  _Repo(this.detail);

  final SeriesDetail detail;

  int episodeDetailCalls = 0;

  @override
  Future<Result<SeriesDetail>> seriesDetail(String slug) async => Ok(detail);

  @override
  Future<Result<EpisodeDetail>> episodeDetail(String slug) async {
    episodeDetailCalls++;
    return Ok(
      EpisodeDetail(
        id: 'd',
        slug: slug,
        title: 'Tập $slug',
        seriesSlug: 's',
        seriesTitle: 'S',
        narrations: const [],
        hasQuiz: slug == 'a',
      ),
    );
  }

  @override
  Future<Result<List<HistoricalEvent>>> events({String? periodId}) =>
      throw UnimplementedError();
  @override
  Future<Result<HistoricalEvent>> eventDetail(String slug) =>
      throw UnimplementedError();
  @override
  Future<Result<List<HistoricalPeriod>>> periods() =>
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
  Future<Result<List<LatestEpisode>>> latestEpisodes() =>
      throw UnimplementedError();
}

Future<GoRouter> _pump(
  WidgetTester tester,
  SeriesDetail detail, {
  _Repo? repo,
}) async {
  final repository = repo ?? _Repo(detail);
  final router = GoRouter(
    initialLocation: '/series/s',
    routes: [
      GoRoute(
        path: '/series/:slug',
        builder: (_, state) =>
            SeriesScreen(slug: state.pathParameters['slug']!),
      ),
      GoRoute(path: AppRoutes.quiz, builder: (_, _) => const Text('quiz')),
    ],
  );
  addTearDown(router.dispose);
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      retry: appRetry,
      overrides: [catalogRepositoryProvider.overrideWithValue(repository)],
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

SeriesDetail _detail({String? description, List<EpisodeSummary>? episodes}) =>
    SeriesDetail(
      id: 's',
      slug: 's',
      title: 'Bạch Đằng 938',
      creatorName: 'Moderator',
      description: description,
      episodes: episodes ?? [_episode('a'), _episode('b')],
    );

void main() {
  testWidgets(
    'shows title, meta line, play button and episodes; hides author',
    (tester) async {
      await _pump(tester, _detail());
      final l = AppLocalizations.of(
        tester.element(find.byType(Scaffold).first),
      );
      expect(find.text('Bạch Đằng 938'), findsOneWidget);
      expect(
        find.text(
          '${l.appName} · ${l.seriesEpisodeCount(2)} · ${l.episodeMinutes(1)}',
        ),
        findsOneWidget,
      );
      expect(find.text('Moderator'), findsNothing);
      expect(find.text(l.episodeList), findsOneWidget);
      expect(find.text('Tập a'), findsOneWidget);
      expect(find.text('Tập b'), findsOneWidget);
      expect(find.byTooltip(l.play), findsWidgets);
    },
  );

  testWidgets('a series without audio shows the notice instead of play', (
    tester,
  ) async {
    await _pump(tester, _detail(episodes: [_episode('a', audio: false)]));
    final l = AppLocalizations.of(tester.element(find.byType(Scaffold).first));
    expect(find.text(l.seriesNoAudio), findsOneWidget);
    expect(find.byTooltip(l.play), findsNothing);
  });

  testWidgets('long description collapses and toggles', (tester) async {
    await _pump(tester, _detail(description: _longDescription));
    final l = AppLocalizations.of(tester.element(find.byType(Scaffold).first));
    Text description() => tester.widget<Text>(find.text(_longDescription));
    expect(description().maxLines, 3);
    await tester.tap(find.text(l.seriesDescriptionMore));
    await tester.pumpAndSettle();
    expect(description().maxLines, isNull);
    expect(find.text(l.seriesDescriptionLess), findsOneWidget);
  });

  testWidgets('short description has no toggle', (tester) async {
    await _pump(tester, _detail(description: 'Ngắn'));
    final l = AppLocalizations.of(tester.element(find.byType(Scaffold).first));
    expect(find.text('Ngắn'), findsOneWidget);
    expect(find.text(l.seriesDescriptionMore), findsNothing);
  });

  testWidgets('episode rows do not fetch episode detail to resolve quizzes', (
    tester,
  ) async {
    final repo = _Repo(_detail());
    await _pump(tester, repo.detail, repo: repo);
    expect(repo.episodeDetailCalls, 0);
    expect(
      find.descendant(
        of: find.byType(EpisodeListTile),
        matching: find.byType(RoundPlay),
      ),
      findsNWidgets(2),
    );
  });
}
