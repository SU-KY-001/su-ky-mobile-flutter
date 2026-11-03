import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/core/error/app_exception.dart';
import 'package:su_ky_mobile/features/series/ui/episode_list_tile.dart';
import 'package:su_ky_mobile/features/series/ui/series_hero.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/audio_view_model.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_providers.dart';
import 'package:su_ky_mobile/shared/catalog/domain/series.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/catalog_states.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

const _notFoundStatus = 404;

class SeriesScreen extends ConsumerWidget {
  const SeriesScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final detail = ref.watch(seriesDetailProvider(slug));
    return AppPage(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.popOrGo(AppRoutes.podcast),
          tooltip: l.back,
          icon: const Icon(Icons.chevron_left),
        ),
        title: Text(l.seriesDetail),
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

class _SeriesBody extends ConsumerWidget {
  const _SeriesBody({required this.series});

  final SeriesDetail series;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final first = series.firstPlayableEpisode;
    final minutes = series.totalMinutes;
    return ListView(
      padding: const EdgeInsets.all(AppDesign.pagePadding),
      children: [
        SeriesHero(series: series),
        const SizedBox(height: AppDesign.gap),
        Wrap(
          spacing: AppDesign.gap,
          children: [
            _Meta(
              Icons.inventory_2_outlined,
              l.seriesEpisodeCount(series.episodes.length),
            ),
            if (minutes > 0) _Meta(Icons.schedule, l.episodeMinutes(minutes)),
          ],
        ),
        if (series.description != null) ...[
          const SizedBox(height: AppDesign.gap),
          Text(
            series.description!,
            style: context.text.bodySmall?.copyWith(height: 1.7),
          ),
        ],
        const SizedBox(height: AppDesign.gap),
        FilledButton.icon(
          onPressed: first == null
              ? null
              : () {
                  // Mock playback until the audio engine lands.
                  ref.read(audioViewModelProvider.notifier).startOver();
                  context.push(AppRoutes.player);
                },
          icon: const Icon(Icons.play_arrow, size: 18),
          label: Text(l.seriesPlayFirst),
        ),
        if (first == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l.seriesNoAudio,
              style: context.text.bodySmall?.copyWith(color: AppDesign.muted),
            ),
          ),
        const SizedBox(height: 22),
        SectionHeading(l.episodeList),
        for (final (index, episode) in series.episodes.indexed)
          EpisodeListTile(position: index, episode: episode),
      ],
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: AppDesign.muted),
      const SizedBox(width: 6),
      Text(
        text,
        style: context.text.bodySmall?.copyWith(color: AppDesign.muted),
      ),
    ],
  );
}
