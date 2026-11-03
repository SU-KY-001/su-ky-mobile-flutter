import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/cache_for.dart';
import '../../../core/error/result.dart';
import '../catalog_constants.dart';
import '../domain/episode.dart';
import '../domain/episode_detail.dart';
import '../domain/historical_period.dart';
import '../domain/series.dart';
import 'catalog_repository.dart';

/// Unwraps a [Result] for `AsyncValue`: errors surface as `AsyncError` with the
/// typed `AppException`, which `appRetry` uses to decide whether to retry.
T _unwrap<T>(Result<T> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final error) => throw error,
};

/// First page of series, optionally for one period (null = all periods).
final seriesListProvider = FutureProvider.autoDispose
    .family<List<SeriesSummary>, String?>((ref, periodId) async {
      ref.cacheFor(CatalogDefaults.staleTime);
      final page = _unwrap(
        await ref
            .watch(catalogRepositoryProvider)
            .listSeries(periodId: periodId),
      );
      return page.items;
    });

final seriesDetailProvider = FutureProvider.autoDispose
    .family<SeriesDetail, String>((ref, slug) async {
      ref.cacheFor(CatalogDefaults.staleTime);
      return _unwrap(
        await ref.watch(catalogRepositoryProvider).seriesDetail(slug),
      );
    });

final episodeDetailProvider = FutureProvider.autoDispose
    .family<EpisodeDetail, String>((ref, slug) async {
      ref.cacheFor(CatalogDefaults.staleTime);
      return _unwrap(
        await ref.watch(catalogRepositoryProvider).episodeDetail(slug),
      );
    });

final periodsProvider = FutureProvider.autoDispose<List<HistoricalPeriod>>((
  ref,
) async {
  ref.cacheFor(CatalogDefaults.staleTime);
  return _unwrap(await ref.watch(catalogRepositoryProvider).periods());
});

final latestEpisodesProvider = FutureProvider.autoDispose<List<LatestEpisode>>((
  ref,
) async {
  ref.cacheFor(CatalogDefaults.staleTime);
  return _unwrap(await ref.watch(catalogRepositoryProvider).latestEpisodes());
});

/// Series whose title matches [query] (server-side `q`).
final seriesSearchProvider = FutureProvider.autoDispose
    .family<List<SeriesSummary>, String>((ref, query) async {
      ref.cacheFor(CatalogDefaults.staleTime);
      final page = _unwrap(
        await ref.watch(catalogRepositoryProvider).listSeries(query: query),
      );
      return page.items;
    });
