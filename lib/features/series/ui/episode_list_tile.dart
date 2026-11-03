import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/audio_time.dart';
import 'package:su_ky_mobile/shared/audio/play_gate.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

import 'episode_quiz_button.dart';

/// Episodes without audio stay visible but dimmed (same as RN).
const _unavailableOpacity = 0.72;

class EpisodeListTile extends ConsumerWidget {
  const EpisodeListTile({
    super.key,
    required this.position,
    required this.episode,
  });

  /// Zero-based position in the series list.
  final int position;
  final EpisodeSummary episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
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
      child: Opacity(
        opacity: narration == null ? _unavailableOpacity : 1,
        child: InkWell(
          onTap: open,
          borderRadius: BorderRadius.circular(AppDesign.radius),
          child: Surface(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppDesign.canvas,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${position + 1}'.padLeft(2, '0'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        durationMs == null
                            ? l.episodeNoAudio
                            : audioTime(
                                durationMs ~/ Duration.millisecondsPerSecond,
                              ),
                        style: context.text.labelSmall?.copyWith(
                          color: AppDesign.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (narration != null)
                  Icon(Icons.play_circle_outline, color: context.accent),
                EpisodeQuizButton(slug: episode.slug),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
