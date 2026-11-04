import 'package:flutter/material.dart';

import 'package:su_ky_mobile/features/weekly_missions/ui/missions_progress_bar.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_missions_colors.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/missions/domain/weekly_missions.dart';

const _starSize = 40.0;
const _gap = 12.0;

/// Top block of the Quests screen: total XP, week end and overall progress.
class WeeklySummary extends StatelessWidget {
  const WeeklySummary({super.key, required this.missions});

  final WeeklyMissions missions;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final total = missions.items.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.stars_rounded,
              size: _starSize,
              color: WeeklyMissionsColors.gold,
            ),
            const SizedBox(width: _gap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${missions.totalXp}',
                    style: context.text.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    l.missionsTotalXp,
                    style: context.text.bodySmall?.copyWith(
                      color: AppDesign.muted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              l.missionsWeekEnd(missions.weekEnd.toLocal()),
              style: context.text.bodySmall?.copyWith(color: AppDesign.muted),
            ),
          ],
        ),
        const SizedBox(height: _gap),
        MissionsProgressBar(
          progress: total == 0 ? 0 : missions.completedCount / total,
          color: WeeklyMissionsColors.green,
        ),
        const SizedBox(height: 6),
        Text(
          '${l.missionsCompletedLabel} · '
          '${l.missionsProgressRatio(missions.completedCount, total)}',
          style: context.text.labelMedium?.copyWith(color: AppDesign.muted),
        ),
      ],
    );
  }
}
