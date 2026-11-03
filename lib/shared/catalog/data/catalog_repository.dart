import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/result.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/network/dio_factory.dart';
import '../catalog_constants.dart';
import '../domain/episode.dart';
import '../domain/historical_period.dart';
import '../domain/paged.dart';
import '../domain/series.dart';
import 'catalog_parser.dart';

const _seriesPath = '/api/series';
const _periodsPath = '/api/historical-periods';
const _notFoundStatus = 404;
const _notFoundCode = 'NOT_FOUND';

abstract class CatalogRepository {
  Future<Result<Paged<SeriesSummary>>> listSeries({
    int page = 1,
    int limit = CatalogDefaults.seriesPageSize,
    String? query,
    String? periodId,
  });
  Future<Result<SeriesDetail>> seriesDetail(String slug);
  Future<Result<List<HistoricalPeriod>>> periods();

  /// Newest playable episodes across the first series. The API has no
  /// episode list endpoint, so this fans out to series details (as RN does).
  Future<Result<List<LatestEpisode>>> latestEpisodes();
}

class ApiCatalogRepository implements CatalogRepository {
  ApiCatalogRepository(this._dio);

  final Dio _dio;

  @override
  Future<Result<Paged<SeriesSummary>>> listSeries({
    int page = 1,
    int limit = CatalogDefaults.seriesPageSize,
    String? query,
    String? periodId,
  }) => _guard('Series list', () async {
    final res = await _dio.get<Object?>(
      _seriesPath,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        'periodId': ?periodId,
      },
    );
    return CatalogParser.seriesPage(res.data);
  });

  @override
  Future<Result<SeriesDetail>> seriesDetail(String slug) {
    if (!isValidSlug(slug)) {
      return Future.value(
        const Err(
          ApiException(
            'Invalid series slug',
            statusCode: _notFoundStatus,
            errorCode: _notFoundCode,
          ),
        ),
      );
    }
    return _guard('Series detail', () async {
      final res = await _dio.get<Object?>('$_seriesPath/$slug');
      return CatalogParser.seriesDetail(res.data);
    });
  }

  @override
  Future<Result<List<HistoricalPeriod>>> periods() =>
      _guard('Historical periods', () async {
        final res = await _dio.get<Object?>(_periodsPath);
        return CatalogParser.periods(res.data);
      });

  @override
  Future<Result<List<LatestEpisode>>> latestEpisodes() async {
    final list = await listSeries(limit: CatalogDefaults.latestSeriesScanCount);
    final List<SeriesSummary> series;
    switch (list) {
      case Err(:final error):
        return Err(error);
      case Ok(:final value):
        series = value.items;
    }
    final details = await Future.wait(
      series.take(CatalogDefaults.latestSeriesScanCount).map((summary) {
        return seriesDetail(summary.slug);
      }),
    );
    final episodes = <LatestEpisode>[];
    AppException? firstError;
    var failures = 0;
    for (final result in details) {
      switch (result) {
        case Ok(:final value):
          for (final episode in value.episodes) {
            if (episode.playable == null) continue;
            episodes.add(
              LatestEpisode(
                seriesSlug: value.slug,
                seriesTitle: value.title,
                episode: episode,
              ),
            );
          }
        case Err(:final error):
          failures++;
          AppLogger.error('Latest episodes: series skipped', error: error);
          firstError ??= error;
      }
    }
    // A partial failure still shows what loaded; only total failure is an error.
    if (firstError != null && failures == details.length) {
      return Err(firstError);
    }
    episodes.sort((a, b) => _newestFirst(a.episode, b.episode));
    return Ok(episodes.take(CatalogDefaults.latestEpisodesCount).toList());
  }

  int _newestFirst(EpisodeSummary a, EpisodeSummary b) {
    final left = a.publishedAt, right = b.publishedAt;
    if (left == null && right == null) return 0;
    if (left == null) return 1;
    if (right == null) return -1;
    return right.compareTo(left);
  }

  Future<Result<T>> _guard<T>(String what, Future<T> Function() call) async {
    try {
      return Ok(await call());
    } on DioException catch (e) {
      final error = e.error;
      return Err(error is AppException ? error : mapDioException(e));
    } on AppException catch (e) {
      return Err(e);
    } on FormatException catch (e, stack) {
      AppLogger.error('$what: unexpected payload', error: e, stackTrace: stack);
      return Err(UnknownException('$what: unexpected payload', cause: e));
    } catch (e, stack) {
      AppLogger.error('$what failed', error: e, stackTrace: stack);
      return Err(UnknownException('$what failed', cause: e));
    }
  }
}

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => ApiCatalogRepository(ref.watch(dioProvider)),
);
