import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/features/podcast/ui/podcast_banner.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_providers.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/catalog_states.dart';
import 'package:su_ky_mobile/shared/widgets/latest_episodes_section.dart';
import 'package:su_ky_mobile/shared/widgets/series_carousel.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

class PodcastScreen extends ConsumerWidget {
  const PodcastScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final series = ref.watch(seriesListProvider(null));
    return AppPage(
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(seriesListProvider(null));
          ref.invalidate(latestEpisodesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(AppDesign.pagePadding),
          children: [
            Text(
              l.podcastTitle,
              style: context.text.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDesign.pagePadding),
            CatalogAsyncView(
              value: series,
              onRetry: () => ref.invalidate(seriesListProvider(null)),
              isEmpty: (items) => items.isEmpty,
              emptyTitle: l.podcastEmptyTitle,
              emptyMessage: l.podcastEmptyMessage,
              builder: (items) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PodcastBanner(series: featuredSeriesOf(items)),
                  SectionHeading(l.podcastSeriesHeading),
                  SeriesCarousel(series: items),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const LatestEpisodesSection(),
          ],
        ),
      ),
    );
  }
}
