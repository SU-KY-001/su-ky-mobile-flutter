import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/domain/series.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/cover_art.dart';

const shelfCoverSize = 150.0;
const _titleGap = 8.0;

/// Spotify-style shelf item: square cover, 2-line title, 1-line episode count.
class ShelfCard extends StatelessWidget {
  const ShelfCard({super.key, required this.series, required this.onTap});

  final SeriesSummary series;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SizedBox(
      width: shelfCoverSize,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDesign.coverRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CoverArt(
              url: series.coverUrl,
              seed: series.slug,
              height: shelfCoverSize,
              width: shelfCoverSize,
            ),
            const SizedBox(height: _titleGap),
            Text(
              series.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              l.seriesEpisodeCount(series.episodeCount),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodySmall?.copyWith(color: AppDesign.muted),
            ),
          ],
        ),
      ),
    );
  }
}
