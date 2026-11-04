import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/domain/series.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/cover_art.dart';

const _coverSize = 150.0;
const _itemGap = 12.0;
const _textGap = 8.0;
const _titleLines = 2;
const _shelfHeight = 232.0;

/// Spotify-style shelf: square covers, title (2 lines) and episode count.
class PodcastSeriesShelf extends StatelessWidget {
  const PodcastSeriesShelf({super.key, required this.series});

  final List<SeriesSummary> series;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: _shelfHeight,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: series.length,
      separatorBuilder: (_, _) => const SizedBox(width: _itemGap),
      itemBuilder: (_, index) => _ShelfItem(series: series[index]),
    ),
  );
}

class _ShelfItem extends StatelessWidget {
  const _ShelfItem({required this.series});

  final SeriesSummary series;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: _coverSize,
    child: InkWell(
      onTap: () => context.push(AppRoutes.seriesFor(series.slug)),
      borderRadius: BorderRadius.circular(AppDesign.coverRadius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CoverArt(
            url: series.coverUrl,
            seed: series.slug,
            height: _coverSize,
            width: _coverSize,
          ),
          const SizedBox(height: _textGap),
          Text(
            series.title,
            maxLines: _titleLines,
            overflow: TextOverflow.ellipsis,
            style: context.text.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            AppLocalizations.of(context)
                .seriesEpisodeCount(series.episodeCount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodySmall?.copyWith(color: AppDesign.muted),
          ),
        ],
      ),
    ),
  );
}
