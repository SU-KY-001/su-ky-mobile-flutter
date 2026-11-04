import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/features/podcast/ui/podcast_banner.dart';
import 'package:su_ky_mobile/features/podcast/ui/podcast_latest_section.dart';
import 'package:su_ky_mobile/features/podcast/ui/podcast_series_shelf.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_providers.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/catalog_states.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

const _sectionGap = 20.0;

class PodcastScreen extends ConsumerWidget {
  const PodcastScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final series = ref.watch(seriesListProvider(null));
    return AppPage(
      appBar: AppBar(title: Text(l.podcastTitle)),
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(seriesListProvider(null));
          ref.invalidate(latestEpisodesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(AppDesign.pagePadding),
          children: [
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
                  const SizedBox(height: _sectionGap),
                  SectionHeading(l.podcastSeriesHeading),
                  PodcastSeriesShelf(series: items),
                ],
              ),
            ),
            const SizedBox(height: _sectionGap),
            const PodcastLatestSection(),
          ],
        ),
      ),
    );
  }
}
