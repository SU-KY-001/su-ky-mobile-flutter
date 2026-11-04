import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/core/error/app_exception.dart';
import 'package:su_ky_mobile/features/series/ui/episode_list_tile.dart';
import 'package:su_ky_mobile/features/series/ui/series_header.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_providers.dart';
import 'package:su_ky_mobile/shared/catalog/domain/series.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/catalog_states.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

const _notFoundStatus = 404;
const _headingGap = 28.0;
const _listGap = 8.0;

class SeriesScreen extends ConsumerWidget {
  const SeriesScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final detail = ref.watch(seriesDetailProvider(slug));
    return AppPage(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.popOrGo(AppRoutes.podcast),
        ),
      ),
      child: detail.when(
        loading: () => const CatalogLoading(),
        error: (error, _) =>
            error is ApiException && error.statusCode == _notFoundStatus
            ? _SeriesNotFound(message: l.seriesNotFound)
            : CatalogError(
                error: error,
                onRetry: () => ref.invalidate(seriesDetailProvider(slug)),
              ),
        data: (series) => _SeriesBody(series: series),
      ),
    );
  }
}

class _SeriesNotFound extends StatelessWidget {
  const _SeriesNotFound({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      CatalogEmpty(message: message),
      TextButton(
        onPressed: () => context.go(AppRoutes.podcast),
        child: Text(AppLocalizations.of(context).seriesBackToPodcast),
      ),
    ],
  );
}

class _SeriesBody extends StatelessWidget {
  const _SeriesBody({required this.series});

  final SeriesDetail series;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppDesign.pagePadding),
    children: [
      SeriesHeader(series: series),
      const SizedBox(height: _headingGap),
      SectionHeading(AppLocalizations.of(context).episodeList),
      const SizedBox(height: _listGap),
      for (var i = 0; i < series.episodes.length; i++) ...[
        if (i > 0) const Divider(height: 1),
        EpisodeListTile(episode: series.episodes[i], number: i + 1),
      ],
    ],
  );
}
