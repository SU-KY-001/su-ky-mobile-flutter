import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/catalog_constants.dart';
import 'package:su_ky_mobile/shared/catalog/domain/series.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/series_card.dart';

/// The banner series: the RN featured slug when present, else the first.
/// [series] must not be empty.
SeriesSummary featuredSeriesOf(List<SeriesSummary> series) => series.firstWhere(
  (s) => s.slug == CatalogDefaults.featuredSeriesSlug,
  orElse: () => series.first,
);

class PodcastBanner extends StatelessWidget {
  const PodcastBanner({super.key, required this.series});

  final SeriesSummary series;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.podcastFeatured,
          style: context.text.labelSmall?.copyWith(
            color: context.accent,
            letterSpacing: .8,
          ),
        ),
        const SizedBox(height: 8),
        SeriesCard(
          series: series,
          large: true,
          onTap: () => context.push(AppRoutes.seriesFor(series.slug)),
        ),
        const SizedBox(height: AppDesign.pagePadding),
      ],
    );
  }
}
