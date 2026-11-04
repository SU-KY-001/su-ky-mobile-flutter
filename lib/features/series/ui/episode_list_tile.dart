import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/audio_time.dart';
import 'package:su_ky_mobile/shared/audio/play_gate.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

/// Episodes without audio stay visible but dimmed (same as RN).
const _unavailableOpacity = 0.72;
const _rowPadding = 12.0;
const _indexWidth = 32.0;
const _textGap = 4.0;
const _playSize = AppDesign.tapTarget;
const _metaSeparator = ' · ';

/// Album track row: number, title, muted description, meta line and a
/// trailing circular play button. Quiz entry lives in the Quiz tab and the
/// player, so the row never triggers a per-episode detail request.
class EpisodeListTile extends ConsumerWidget {
  const EpisodeListTile({
    super.key,
    required this.episode,
    required this.number,
  });

  final EpisodeSummary episode;

  /// 1-based position in the series, like a track number.
  final int number;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final narration = episode.playable;
    final durationMs = narration?.durationMs;
    final publishedAt = episode.publishedAt;
    final description = episode.description;
    void open() {
      if (narration == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.episodeNoAudioNotice)));
        return;
      }
      playFromUi(context, ref, episode.slug, narrationId: narration.id);
    }

    final meta = [
      if (publishedAt != null) DateFormat.yMd(l.localeName).format(publishedAt),
      durationMs == null
          ? l.episodeNoAudio
          : audioTime(durationMs ~/ Duration.millisecondsPerSecond),
    ].join(_metaSeparator);
    return Opacity(
      opacity: narration == null ? _unavailableOpacity : 1,
      child: InkWell(
        onTap: open,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: _rowPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: _indexWidth,
                child: Text(
                  '$number',
                  style: context.text.titleSmall?.copyWith(
                    color: AppDesign.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
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
                    if (description != null) ...[
                      const SizedBox(height: _textGap),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall?.copyWith(
                          color: AppDesign.muted,
                        ),
                      ),
                    ],
                    const SizedBox(height: _textGap),
                    Text(
                      meta,
                      style: context.text.labelSmall?.copyWith(
                        color: AppDesign.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (narration != null)
                RoundPlay(onTap: open, size: _playSize, filled: false),
            ],
          ),
        ),
      ),
    );
  }
}
