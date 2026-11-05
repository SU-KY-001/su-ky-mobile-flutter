import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/play_gate.dart';
import 'package:su_ky_mobile/shared/catalog/domain/series.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/cover_art.dart';
import 'package:su_ky_mobile/shared/widgets/expandable_description.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

const _coverAspect = 4 / 3;
const _playSize = 56.0;
const _titleGap = 16.0;
const _metaGap = 4.0;
const _actionGap = 16.0;
const _metaSeparator = ' · ';

/// Album-style header: a wide cover across the page, left-aligned title and
/// meta, one round play button on the left, then the plain description.
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
        AspectRatio(
          aspectRatio: _coverAspect,
          child: LayoutBuilder(
            builder: (_, box) => CoverArt(
              url: series.landscapeUrl ?? series.coverUrl,
              seed: series.slug,
              height: box.maxHeight,
              width: box.maxWidth,
            ),
          ),
        ),
        const SizedBox(height: _titleGap),
        Text(
          series.title,
          style: context.text.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: _metaGap),
        Text(
          meta,
          style: context.text.bodySmall?.copyWith(color: AppDesign.muted),
        ),
        const SizedBox(height: _actionGap),
        if (first == null)
          Text(
            l.seriesNoAudio,
            style: context.text.bodySmall?.copyWith(color: AppDesign.muted),
          )
        else
          RoundPlay(
            size: _playSize,
            onTap: () => playFromUi(
              context,
              ref,
              first.slug,
              narrationId: first.playable?.id,
            ),
          ),
        if (description != null) ...[
          const SizedBox(height: _actionGap),
          ExpandableDescription(text: description),
        ],
      ],
    );
  }
}
