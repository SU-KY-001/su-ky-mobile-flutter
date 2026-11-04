import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:su_ky_mobile/features/schedule/domain/release.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/play_gate.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

const _calendarSize = 16.0;
const _calendarGap = 8.0;
const _statusGap = 4.0;
const _playSize = 36.0;

class ReleaseTile extends ConsumerWidget {
  const ReleaseTile({super.key, required this.release});

  final Release release;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final scheduledAt = release.scheduledAt.toLocal();
    final date = DateFormat.yMMMd(l.localeName).add_Hm().format(scheduledAt);
    return Surface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.event_outlined,
            size: _calendarSize,
            color: AppDesign.muted,
          ),
          const SizedBox(width: _calendarGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: context.text.bodySmall?.copyWith(
                    color: AppDesign.muted,
                  ),
                ),
                const SizedBox(height: _statusGap),
                Text(
                  release.title,
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: _statusGap),
                Text(
                  release.seriesTitle,
                  style: context.text.bodySmall?.copyWith(
                    color: AppDesign.muted,
                  ),
                ),
                const SizedBox(height: _statusGap),
                Text(
                  release.released ? l.scheduleReleased : l.scheduleUpcoming,
                  style: context.text.labelSmall?.copyWith(
                    color: release.released ? context.accent : AppDesign.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (release.released)
            Padding(
              padding: const EdgeInsets.only(left: _calendarGap),
              child: RoundPlay(
                size: _playSize,
                onTap: () => playFromUi(context, ref, release.episodeSlug),
              ),
            ),
        ],
      ),
    );
  }
}
