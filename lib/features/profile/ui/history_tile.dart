import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/play_gate.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/history/domain/listening_history.dart';
import 'package:su_ky_mobile/shared/widgets/cover_art.dart';

const _unavailableOpacity = 0.55;
const _thumb = 56.0;
const _progressHeight = 2.0;
const _rowPadding = EdgeInsets.symmetric(vertical: 8);
const _gap = 12.0;

/// Spotify "Recently played" row: art, title, series, progress line, play.
class HistoryTile extends ConsumerWidget {
  const HistoryTile({super.key, required this.entry});

  final HistoryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final play = entry.available
        ? () => playFromUi(
            context,
            ref,
            entry.episodeSlug,
            narrationId: entry.narrationId,
            autoplay: false,
          )
        : null;
    return Opacity(
      opacity: entry.available ? 1 : _unavailableOpacity,
      child: InkWell(
        onTap: play,
        child: Padding(
          padding: _rowPadding,
          child: Row(
            children: [
              CoverArt(seed: entry.episodeSlug, height: _thumb, width: _thumb),
              const SizedBox(width: _gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.episodeTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      l.profileHistoryProgress(
                        entry.seriesTitle,
                        entry.percent,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall?.copyWith(
                        color: AppDesign.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: entry.progress,
                      minHeight: _progressHeight,
                      backgroundColor: AppDesign.line,
                      color: context.accent,
                    ),
                  ],
                ),
              ),
              SizedBox.square(
                dimension: AppDesign.tapTarget,
                child: play == null
                    ? null
                    : Icon(Symbols.play_arrow, color: context.accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
