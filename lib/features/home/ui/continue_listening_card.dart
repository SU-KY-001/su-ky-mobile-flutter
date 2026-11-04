import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/local_playback_store.dart';
import 'package:su_ky_mobile/shared/audio/play_gate.dart';
import 'package:su_ky_mobile/shared/audio/playback_providers.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_providers.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode_detail.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/cover_art.dart';

const _thumbSize = 56.0;
const _rowHeight = 72.0;
const _gap = 12.0;
const _progressHeight = 2.0;
const _playIconSize = 32.0;

/// Spotify "Jump back in" row resuming the last episode; hidden when there
/// is none.
class ContinueListeningCard extends ConsumerWidget {
  const ContinueListeningCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final last = ref.watch(lastListenProvider);
    if (last == null) return const SizedBox.shrink();
    final episode = ref.watch(episodeDetailProvider(last.slug));
    return episode.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (detail) =>
          _ContinueRow(episode: detail, narrationId: last.narrationId),
    );
  }
}

class _ContinueRow extends ConsumerWidget {
  const _ContinueRow({required this.episode, required this.narrationId});

  final EpisodeDetail episode;
  final String narrationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    void resume() =>
        playFromUi(context, ref, episode.slug, narrationId: narrationId);
    final durationMs = episode.playableFor(narrationId)?.durationMs;
    final positionMs =
        ref.watch(localPlaybackStoreProvider).position(narrationId) *
        Duration.millisecondsPerSecond;
    final hasProgress = durationMs != null && durationMs > 0;
    final remainingMinutes = hasProgress
        ? ((durationMs - positionMs).clamp(0, durationMs) /
                  Duration.millisecondsPerMinute)
              .ceil()
        : 0;
    return InkWell(
      onTap: resume,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDesign.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: _rowHeight,
              child: Row(
                children: [
                  CoverArt(
                    url: episode.seriesCoverUrl,
                    seed: episode.seriesSlug,
                    height: _thumbSize,
                    width: _thumbSize,
                  ),
                  const SizedBox(width: _gap),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          episode.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          hasProgress
                              ? l.continueRemainingLine(
                                  episode.seriesTitle,
                                  remainingMinutes,
                                )
                              : episode.seriesTitle,
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
                    onPressed: resume,
                    tooltip: l.play,
                    iconSize: _playIconSize,
                    icon: const Icon(Icons.play_circle_outline),
                  ),
                ],
              ),
            ),
            if (hasProgress)
              LinearProgressIndicator(
                value: (positionMs / durationMs).clamp(0.0, 1.0),
                minHeight: _progressHeight,
              ),
          ],
        ),
      ),
    );
  }
}
