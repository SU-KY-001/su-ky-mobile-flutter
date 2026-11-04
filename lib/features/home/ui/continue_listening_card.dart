import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/play_gate.dart';
import 'package:su_ky_mobile/shared/audio/playback_providers.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_providers.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode_detail.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/cover_art.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

const _thumbSize = 56.0;
const _headGap = 12.0;
const _lineGap = 4.0;
const _textGap = 12.0;

/// Home card resuming the last listened episode; hidden when there is none.
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
          _ContinueCard(episode: detail, narrationId: last.narrationId),
    );
  }
}

class _ContinueCard extends ConsumerWidget {
  const _ContinueCard({required this.episode, required this.narrationId});

  final EpisodeDetail episode;
  final String narrationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    void resume() =>
        playFromUi(context, ref, episode.slug, narrationId: narrationId);
    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.continueListening,
            style: context.text.labelSmall?.copyWith(
              color: context.accent,
              letterSpacing: .8,
            ),
          ),
          const SizedBox(height: _headGap),
          InkWell(
            onTap: resume,
            borderRadius: BorderRadius.circular(AppDesign.radius),
            child: Row(
              children: [
                CoverArt(
                  url: episode.seriesCoverUrl,
                  seed: episode.seriesSlug,
                  height: _thumbSize,
                  width: _thumbSize,
                ),
                const SizedBox(width: _textGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        episode.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: _lineGap),
                      Text(
                        l.playerSeriesLine(episode.seriesTitle),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall?.copyWith(
                          color: AppDesign.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: _textGap),
                RoundPlay(onTap: resume),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
