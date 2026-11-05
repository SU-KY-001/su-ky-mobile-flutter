import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/shared/catalog/catalog_constants.dart';
import 'package:su_ky_mobile/shared/catalog/domain/series.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/cover_art.dart';

const _heroAspectRatio = 16 / 9;
const _scrimTopAlpha = 0.0;
const _titlePadding = 16.0;
const _titleMaxLines = 2;

/// The banner series: the RN featured slug when present, else the first.
/// [series] must not be empty.
SeriesSummary featuredSeriesOf(List<SeriesSummary> series) => series.firstWhere(
  (s) => s.slug == CatalogDefaults.featuredSeriesSlug,
  orElse: () => series.first,
);

/// Apple Podcasts "Featured": one wide 16:9 cover with the title on top.
class PodcastBanner extends StatelessWidget {
  const PodcastBanner({super.key, required this.series});

  final SeriesSummary series;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(AppDesign.radius),
    child: AspectRatio(
      aspectRatio: _heroAspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CoverArt(
            url: series.landscapeUrl ?? series.coverUrl,
            seed: series.slug,
            height: double.infinity,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: _scrimTopAlpha),
                  Colors.black87,
                ],
              ),
            ),
          ),
          Positioned(
            left: _titlePadding,
            right: _titlePadding,
            bottom: _titlePadding,
            child: Text(
              series.title,
              maxLines: _titleMaxLines,
              overflow: TextOverflow.ellipsis,
              style: context.text.titleLarge?.copyWith(
                color: AppDesign.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () => context.push(AppRoutes.seriesFor(series.slug)),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
