import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/features/schedule/domain/release.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/play_gate.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/cover_art.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

const _artSize = 56.0;
const _rowPadding = EdgeInsets.symmetric(
  horizontal: AppDesign.pagePadding,
  vertical: 8,
);
const _statusGap = 2.0;

/// Apple Podcasts "Upcoming" row: 56 art, title, series, status, trailing
/// play (released) or bell (coming soon).
class ReleaseTile extends ConsumerWidget {
  const ReleaseTile({super.key, required this.release});

  final Release release;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final released = release.released;
    return Padding(
      padding: _rowPadding,
      child: Row(
        children: [
          CoverArt(
            seed: release.episodeSlug,
            height: _artSize,
            width: _artSize,
          ),
          const SizedBox(width: AppDesign.gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  release.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  release.seriesTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall?.copyWith(
                    color: AppDesign.muted,
                  ),
                ),
                const SizedBox(height: _statusGap),
                Text(
                  released ? l.scheduleReleased : l.scheduleUpcoming,
                  style: context.text.labelSmall?.copyWith(
                    color: released ? context.accent : AppDesign.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (released)
            RoundPlay(
              size: AppDesign.tapTarget,
              onTap: () => playFromUi(context, ref, release.episodeSlug),
            )
          else
            const SizedBox.square(
              dimension: AppDesign.tapTarget,
              child: Icon(Icons.notifications_none, color: AppDesign.muted),
            ),
        ],
      ),
    );
  }
}
