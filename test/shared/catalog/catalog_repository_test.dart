import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:su_ky_mobile/core/error/app_exception.dart';
import 'package:su_ky_mobile/core/error/result.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_repository.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode_detail.dart';
import 'package:su_ky_mobile/shared/catalog/domain/historical_event.dart';
import 'package:su_ky_mobile/shared/catalog/domain/historical_period.dart';
import 'package:su_ky_mobile/shared/catalog/domain/paged.dart';
import 'package:su_ky_mobile/shared/catalog/domain/series.dart';

import '../../support/stub_http.dart';

Map<String, Object?> _series({
  String slug = 'bach-dang',
  Object? cover = const {'url': 'https://img/c.jpg'},
}) => {
  'id': 'id-$slug',
  'slug': slug,
  'title': 'Series $slug',
  'description': null,
  'startYear': 938,
  'endYear': null,
  'cover': cover,
  'coverLandscape': null,
  'episodeCount': 6,
  'publishedAt': '2026-10-01T00:00:00.000Z',
};

Map<String, Object?> _narration({
  bool available = true,
  String type = 'FIRST_PERSON',
}) => {'id': 'n1', 'type': type, 'available': available, 'durationMs': 90000};

Map<String, Object?> _episode(
  String slug,
  String? published, {
  bool available = true,
}) => {
  'id': 'e-$slug',
  'slug': slug,
  'title': 'Ep $slug',
  'description': 'd',
  'publishedAt': published,
  'poster': null,
  'sortOrder': 1,
  'narrations': [_narration(available: available)],
};

Map<String, Object?> _detail(String slug, List<Object?> episodes) => {
  ..._series(slug: slug),
  'creator': {'name': 'Ann'},
  'episodes': episodes,
};

Map<String, Object?> _event({
  String slug = 'tran-bach-dang',
  Object? phase = const {'name': 'P'},
}) => {
  'id': 'ev1',
  'slug': slug,
  'name': 'Trận Bạch Đằng',
  'summary': 's',
  'timeLabel': 'Khoảng 500 TCN - Khoảng 111 TCN',
  'parent': {
    'period': {'name': 'Thời kỳ'},
    'phase': phase,
  },
  'citations': [
    {
      'locator': 'tr. 4',
      'excerpt': null,
      'source': {'title': 'Đại Việt sử ký', 'author': null},
    },
  ],
};

ApiCatalogRepository _repo(StubHandler h) =>
    ApiCatalogRepository(stubDio(h).$1);

void main() {
  group('series list', () {
    test('parses a page and trims the query, dropping empty filters', () async {
      final (dio, adapter) = stubDio(
        (_) => StubReply(200, {
          'items': [_series(), _series(slug: 'no-cover', cover: null)],
          'page': 1,
          'limit': 20,
          'total': 2,
        }),
      );
      final r = await ApiCatalogRepository(dio).listSeries(query: '  bạch ');
      final page = (r as Ok<Paged<SeriesSummary>>).value;
      expect(page.items.map((s) => s.slug), ['bach-dang', 'no-cover']);
      expect(page.items.last.coverUrl, isNull);
      expect(page.items.first.publishedAt, isNotNull);
      expect(adapter.requests.single.queryParameters['q'], 'bạch');
      expect(
        adapter.requests.single.queryParameters.containsKey('periodId'),
        isFalse,
      );
    });

    test('a blank query is not sent', () async {
      final (dio, adapter) = stubDio(
        (_) => const StubReply(200, {
          'items': <Object?>[],
          'page': 1,
          'limit': 20,
          'total': 0,
        }),
      );
      final r = await ApiCatalogRepository(dio).listSeries(query: '   ');
      expect((r as Ok<Paged<SeriesSummary>>).value.items, isEmpty);
      expect(adapter.requests.single.queryParameters.containsKey('q'), isFalse);
    });

    test(
      'a wrong field type fails the whole page as UnknownException',
      () async {
        final r = await _repo(
          (_) => StubReply(200, {
            'items': [
              {..._series(), 'episodeCount': '6'},
            ],
            'page': 1,
            'limit': 20,
            'total': 1,
          }),
        ).listSeries();
        expect((r as Err<Paged<SeriesSummary>>).error, isA<UnknownException>());
      },
    );
  });

  group('details', () {
    test('an invalid slug never reaches the network', () async {
      final (dio, adapter) = stubDio((_) => const StubReply(200, {}));
      final repo = ApiCatalogRepository(dio);
      final r = await repo.seriesDetail('../admin');
      expect((r as Err<SeriesDetail>).error, isA<ApiException>());
      expect(await repo.episodeDetail('Bad Slug'), isA<Err<EpisodeDetail>>());
      expect(await repo.eventDetail('x/y'), isA<Err<HistoricalEvent>>());
      expect(adapter.requests, isEmpty);
    });

    test('series detail parses episodes and creator', () async {
      final r = await _repo(
        (_) => StubReply(200, _detail('bach-dang', [_episode('e1', null)])),
      ).seriesDetail('bach-dang');
      final d = (r as Ok<SeriesDetail>).value;
      expect(d.creatorName, 'Ann');
      expect(
        d.episodes.single.narrations.single.type,
        NarrationType.firstPerson,
      );
    });

    test('an unknown narration type is rejected', () async {
      final bad = _episode('e1', null);
      bad['narrations'] = [_narration(type: 'ROBOT')];
      final r = await _repo((_) => StubReply(200, _detail('bach-dang', [bad])))
          .seriesDetail('bach-dang');
      expect(r, isA<Err<SeriesDetail>>());
    });

    test('a 404 is an ApiException with its status', () async {
      final r = await _repo(
        (_) =>
            const StubReply(404, {'error_code': 'NOT_FOUND', 'message': 'x'}),
      ).seriesDetail('missing');
      expect(((r as Err<SeriesDetail>).error as ApiException).statusCode, 404);
    });

    test(
      'episode detail requires a bool hasQuiz and reads prev/next links',
      () async {
        Map<String, Object?> ep({Object? hasQuiz = true}) => {
          'id': 'e1',
          'slug': 'e1',
          'title': 'T',
          'description': null,
          'series': {'slug': 's', 'title': 'S', 'cover': null},
          'narrations': [_narration()],
          'previousEpisode': null,
          'nextEpisode': {'id': 'e2', 'slug': 'e2', 'title': 'Next'},
          'hasQuiz': hasQuiz,
        };
        final ok = await _repo((_) => StubReply(200, ep())).episodeDetail('e1');
        final d = (ok as Ok<EpisodeDetail>).value;
        expect(d.previous, isNull);
        expect(d.next?.slug, 'e2');
        expect(d.hasQuiz, isTrue);

        final bad = await _repo((_) => StubReply(200, ep(hasQuiz: 'yes')))
            .episodeDetail('e1');
        expect(bad, isA<Err<EpisodeDetail>>());
      },
    );
  });

  group('periods and events', () {
    test('parses periods with optional years', () async {
      final r = await _repo(
        (_) => const StubReply(200, {
          'items': [
            {
              'id': 'p',
              'slug': 'p',
              'name': 'Thời Lý',
              'startYear': null,
              'endYear': 1225,
            },
          ],
        }),
      ).periods();
      final p = (r as Ok<List<HistoricalPeriod>>).value.single;
      expect(p.startYear, isNull);
      expect(p.endYear, 1225);
    });

    test(
      'keeps the BCE label verbatim and optional excerpt/author null',
      () async {
        final r = await _repo(
          (_) => StubReply(200, {
            'items': [_event()],
          }),
        ).events();
        final e = (r as Ok<List<HistoricalEvent>>).value.single;
        expect(e.timeLabel, 'Khoảng 500 TCN - Khoảng 111 TCN');
        expect(e.citations.single.excerpt, isNull);
        expect(e.citations.single.sourceAuthor, isNull);
      },
    );

    test('a broken row is skipped, the good one is kept', () async {
      final r = await _repo(
        (_) => StubReply(200, {
          'items': [_event(phase: null), _event(slug: 'ok-event')],
        }),
      ).events();
      expect((r as Ok<List<HistoricalEvent>>).value.map((e) => e.slug), [
        'ok-event',
      ]);
    });

    test('a missing items list fails the request', () async {
      final r = await _repo((_) => const StubReply(200, {})).events();
      expect(r, isA<Err<List<HistoricalEvent>>>());
    });

    test('events sends periodId and the server page limit', () async {
      final (dio, adapter) = stubDio(
        (_) => const StubReply(200, {'items': <Object?>[]}),
      );
      await ApiCatalogRepository(dio).events(periodId: 'p1');
      expect(adapter.requests.single.queryParameters, {
        'page': 1,
        'limit': 50,
        'periodId': 'p1',
      });
    });

    test('event detail rejects an invalid slug in the payload', () async {
      final r = await _repo((_) => StubReply(200, _event(slug: 'Bad Slug')))
          .eventDetail('ok');
      expect(r, isA<Err<HistoricalEvent>>());
    });
  });

  group('latestEpisodes', () {
    StubReply handler(RequestOptions o, {Set<String> failing = const {}}) {
      if (o.path == '/api/series') {
        return StubReply(200, {
          'items': [_series(slug: 'a'), _series(slug: 'b')],
          'page': 1,
          'limit': 6,
          'total': 2,
        });
      }
      final slug = o.path.split('/').last;
      if (failing.contains(slug)) return const StubReply(500, {});
      return StubReply(
        200,
        _detail(slug, [
          _episode('$slug-old', '2026-01-01T00:00:00Z'),
          _episode(
            '$slug-new',
            slug == 'a' ? '2026-09-01T00:00:00Z' : '2026-10-01T00:00:00Z',
          ),
          _episode('$slug-undated', null),
          _episode('$slug-silent', '2026-12-01T00:00:00Z', available: false),
        ]),
      );
    }

    test('sorts newest first, undated last, drops unplayable', () async {
      final r = await _repo(handler).latestEpisodes();
      final slugs = (r as Ok<List<LatestEpisode>>).value
          .map((e) => e.episode.slug)
          .toList();
      expect(slugs.take(2), ['b-new', 'a-new']);
      expect(slugs, isNot(contains('a-silent')));
      expect(slugs.last, anyOf('a-undated', 'b-undated'));
    });

    test('one failing series is skipped, all failing is an error', () async {
      final partial = await _repo((o) => handler(o, failing: {'a'}))
          .latestEpisodes();
      expect(
        (partial as Ok<List<LatestEpisode>>).value.every(
          (e) => e.seriesSlug == 'b',
        ),
        isTrue,
      );
      final all = await _repo((o) => handler(o, failing: {'a', 'b'}))
          .latestEpisodes();
      expect(all, isA<Err<List<LatestEpisode>>>());
    });
  });
}
