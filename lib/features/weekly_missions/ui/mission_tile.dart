import 'package:flutter/material.dart';

import 'package:su_ky_mobile/features/weekly_missions/ui/mission_l10n.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/mission_widgets.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/missions_panel.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_missions_colors.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/missions/domain/weekly_missions.dart';

const _expiredOpacity = 0.55;
const _iconSize = 35.0;
const _glyphSize = 18.0;
const _chipRadius = 5.0;
const _chipPadding = EdgeInsets.symmetric(horizontal: 7, vertical: 3);
const _badgePadding = EdgeInsets.symmetric(horizontal: 6, vertical: 4);

class MissionTile extends StatelessWidget {
  const MissionTile({super.key, required this.mission});

  final WeeklyMission mission;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final completed = mission.status == MissionStatus.completed;
    final expired = mission.status == MissionStatus.expired;
    final label = mission.status.label(l);
    return Opacity(
      opacity: expired ? _expiredOpacity : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: _iconSize,
              height: _iconSize,
              decoration: BoxDecoration(
                color: completed
                    ? WeeklyMissionsColors.doneIconBackground
                    : WeeklyMissionsColors.pendingIconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                mission.icon,
                size: _glyphSize,
                color: completed ? MissionDesign.gold : AppDesign.red,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          mission.title,
                          style: context.text.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: WeeklyMissionsColors.pointsBadge,
                          borderRadius: BorderRadius.circular(_chipRadius),
                        ),
                        child: Padding(
                          padding: _badgePadding,
                          child: Text(
                            l.missionsXpReward(mission.xpReward),
                            style: context.text.labelSmall?.copyWith(
                              color: MissionDesign.gold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.missionsProgressRatio(
                            mission.progressCount,
                            mission.targetCount,
                          ),
                          style: context.text.labelSmall?.copyWith(
                            color: AppDesign.muted,
                          ),
                        ),
                      ),
                      if (label != null)
                        _StatusChip(label: label, status: mission.status),
                    ],
                  ),
                  const SizedBox(height: 7),
                  MissionsProgressBar(progress: mission.progress, height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.status});

  final String label;
  final MissionStatus status;

  @override
  Widget build(BuildContext context) {
    final completed = status == MissionStatus.completed;
    final color = completed ? MissionDesign.green : AppDesign.muted;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: completed
            ? MissionDesign.paleGreen
            : WeeklyMissionsColors.progressTrack,
        borderRadius: BorderRadius.circular(_chipRadius),
      ),
      child: Padding(
        padding: _chipPadding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (completed) ...[
              const Icon(
                Icons.check_circle,
                size: 11,
                color: MissionDesign.green,
              ),
              const SizedBox(width: 3),
            ],
            Text(
              label,
              style: context.text.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
