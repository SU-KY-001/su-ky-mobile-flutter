import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/audio_time.dart';
import 'package:su_ky_mobile/shared/audio/play_gate.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/cover_art.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

const _thumbSize = 48.0;

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

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: open,
        borderRadius: BorderRadius.circular(AppDesign.radius),
        child: Surface(
          padding: const EdgeInsets.all(12),
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
                      latest.seriesTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelSmall?.copyWith(
                        color: AppDesign.muted,
                      ),
                    ),
                    Text(
                      episode.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (durationMs != null)
                      Text(
                        audioTime(durationMs ~/ Duration.millisecondsPerSecond),
                        style: context.text.labelSmall?.copyWith(
                          color: AppDesign.muted,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppDesign.muted),
            ],
          ),
        ),
      ),
    );
  }
}
