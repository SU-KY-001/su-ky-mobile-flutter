import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/audio_time.dart';
import 'package:su_ky_mobile/shared/audio/play_gate.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/cover_art.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

const _thumbSize = 56.0;
const _rowPadding = 8.0;
const _thumbGap = 12.0;
const _playSize = AppDesign.tapTarget;
const _metaSeparator = ' · ';

/// Apple Podcasts list row: art, title, "series · date · duration", play.
class PodcastEpisodeRow extends ConsumerWidget {
  const PodcastEpisodeRow({super.key, required this.latest});

  final LatestEpisode latest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final episode = latest.episode;
    final narration = episode.playable;
    final publishedAt = episode.publishedAt;
    final durationMs = narration?.durationMs;
    // The row opens the player paused; only the play button starts audio.
    void open({required bool autoplay}) {
      if (narration == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.episodeNoAudioNotice)));
        return;
      }
      playFromUi(
        context,
        ref,
        episode.slug,
        narrationId: narration.id,
        autoplay: autoplay,
      );
    }

    final meta = [
      latest.seriesTitle,
      if (publishedAt != null) DateFormat.yMd(l.localeName).format(publishedAt),
      if (durationMs != null)
        audioTime(durationMs ~/ Duration.millisecondsPerSecond),
    ].join(_metaSeparator);
    return InkWell(
      onTap: () => open(autoplay: false),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: _rowPadding),
        child: Row(
          children: [
            CoverArt(
              url: episode.posterUrl,
              seed: episode.slug,
              height: _thumbSize,
              width: _thumbSize,
            ),
            const SizedBox(width: _thumbGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    episode.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(
                      color: AppDesign.muted,
                    ),
                  ),
                ],
              ),
            ),
            if (narration != null)
              RoundPlay(
                onTap: () => open(autoplay: true),
                size: _playSize,
                filled: false,
              ),
          ],
        ),
      ),
    );
  }
}
