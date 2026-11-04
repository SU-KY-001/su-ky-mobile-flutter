import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/features/series/ui/series_description.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/play_gate.dart';
import 'package:su_ky_mobile/shared/catalog/domain/series.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/cover_art.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

const _coverSize = 200.0;
const _playSize = 56.0;
const _titleGap = 16.0;
const _metaGap = 4.0;
const _sectionGap = 8.0;
const _metaSeparator = ' · ';

/// Spotify / Apple Podcasts show header: centered cover, title, meta line,
/// play button on the right and a collapsible description.
class SeriesHeader extends ConsumerWidget {
  const SeriesHeader({super.key, required this.series});

  final SeriesDetail series;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final first = series.firstPlayableEpisode;
    final minutes = series.totalMinutes;
    final description = series.description;
    final meta = [
      l.appName,
      l.seriesEpisodeCount(series.episodes.length),
      if (minutes > 0) l.episodeMinutes(minutes),
    ].join(_metaSeparator);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: CoverArt(
            url: series.coverUrl ?? series.landscapeUrl,
            seed: series.slug,
            height: _coverSize,
            width: _coverSize,
          ),
        ),
        const SizedBox(height: _titleGap),
        SizedBox(
          width: double.infinity,
          child: Text(
            series.title,
            textAlign: TextAlign.center,
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: _metaGap),
        SizedBox(
          width: double.infinity,
          child: Text(
            meta,
            textAlign: TextAlign.center,
            style: context.text.bodySmall?.copyWith(color: AppDesign.muted),
          ),
        ),
        const SizedBox(height: _sectionGap),
        Row(
          children: [
            Expanded(
              child: first == null
                  ? Text(
                      l.seriesNoAudio,
                      style: context.text.bodySmall?.copyWith(
                        color: AppDesign.muted,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            if (first != null)
              RoundPlay(
                size: _playSize,
                onTap: () => playFromUi(
                  context,
                  ref,
                  first.slug,
                  narrationId: first.playable?.id,
                ),
              ),
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: _sectionGap),
          SeriesDescription(text: description),
        ],
      ],
    );
  }
}
