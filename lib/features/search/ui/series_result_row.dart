import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/domain/series.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/cover_art.dart';

const _thumbSize = 56.0;
const _rowHeight = 72.0;
const _gap = 12.0;

/// Spotify search result row: 56 art, title, episode count.
class SeriesResultRow extends StatelessWidget {
  const SeriesResultRow({super.key, required this.series, required this.onTap});

  final SeriesSummary series;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _rowHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesign.pagePadding,
            vertical: 8,
          ),
          child: Row(
            children: [
              CoverArt(
                url: series.coverUrl,
                seed: series.slug,
                height: _thumbSize,
                width: _thumbSize,
              ),
              const SizedBox(width: _gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      series.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l.seriesEpisodeCount(series.episodeCount),
                      style: context.text.bodySmall?.copyWith(
                        color: AppDesign.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
