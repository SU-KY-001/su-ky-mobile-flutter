import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/audio_time.dart';
import 'package:su_ky_mobile/shared/audio/play_gate.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/cover_art.dart';

const _thumbSize = 56.0;
const _rowHeight = 72.0;
const _playIconSize = 32.0;
const _metaSeparator = ' · ';

class LatestEpisodeTile extends ConsumerWidget {
  const LatestEpisodeTile({super.key, required this.latest});

  final LatestEpisode latest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final episode = latest.episode;
    final narration = episode.playable;
    final durationMs = narration?.durationMs;
    void open() {
      if (narration == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.episodeNoAudioNotice)));
        return;
      }
      playFromUi(context, ref, episode.slug, narrationId: narration.id);
    }

    final subtitle = [
      latest.seriesTitle,
      if (durationMs != null)
        audioTime(durationMs ~/ Duration.millisecondsPerSecond),
    ].join(_metaSeparator);
    return InkWell(
      onTap: open,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _rowHeight),
        child: Row(
          children: [
            CoverArt(
              url: episode.posterUrl,
              seed: episode.slug,
              height: _thumbSize,
              width: _thumbSize,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    episode.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(
                      color: AppDesign.muted,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: open,
              tooltip: l.play,
              icon: const Icon(Icons.play_circle_outline),
              iconSize: _playIconSize,
            ),
          ],
        ),
      ),
    );
  }
}
