import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/play_gate.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/history/domain/listening_history.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

const _fullOpacity = 1.0;
const _unavailableOpacity = 0.55;
const _contentPadding = EdgeInsets.all(AppDesign.gap);
const _progressHeight = 6.0;
const _lineGap = 8.0;
const _playIconSize = 18.0;

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
          )
        : null;
    return Opacity(
      opacity: entry.available ? _fullOpacity : _unavailableOpacity,
      child: Surface(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: play,
          borderRadius: BorderRadius.circular(AppDesign.radius),
          child: Padding(
            padding: _contentPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.episodeTitle,
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: _lineGap),
                Text(
                  l.profileHistoryProgress(entry.seriesTitle, entry.percent),
                  style: context.text.bodySmall?.copyWith(
                    color: AppDesign.muted,
                  ),
                ),
                const SizedBox(height: _lineGap),
                ClipRRect(
                  borderRadius: BorderRadius.circular(_progressHeight),
                  child: LinearProgressIndicator(
                    value: entry.progress,
                    minHeight: _progressHeight,
                    backgroundColor: AppDesign.line,
                    color: context.accent,
                  ),
                ),
                if (play != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: play,
                      icon: const Icon(Icons.play_arrow, size: _playIconSize),
                      label: Text(l.continueListening),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
