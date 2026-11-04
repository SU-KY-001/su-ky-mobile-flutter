import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/mission_l10n.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/missions_progress_bar.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_missions_colors.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/missions/domain/weekly_missions.dart';

const _expiredOpacity = 0.55;
const _doneOpacity = 0.7;
const _iconTile = 48.0;
const _glyphSize = 26.0;
const _tileRadius = AppDesign.radius;
const _chipRadius = 8.0;
const _chipPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 4);
const _rowPadding = EdgeInsets.symmetric(vertical: AppDesign.gap);
const _spacing = 12.0;
const _checkSize = 28.0;

/// Duolingo quest row: icon tile, title, thick bar with n/m, XP chip.
class MissionTile extends StatelessWidget {
  const MissionTile({super.key, required this.mission});

  final WeeklyMission mission;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final completed = mission.status == MissionStatus.completed;
    final expired = mission.status == MissionStatus.expired;
    return Opacity(
      opacity: expired
          ? _expiredOpacity
          : completed
          ? _doneOpacity
          : 1,
      child: Padding(
        padding: _rowPadding,
        child: Row(
          children: [
            Container(
              width: _iconTile,
              height: _iconTile,
              decoration: BoxDecoration(
                color: completed
                    ? WeeklyMissionsColors.doneIconBackground
                    : WeeklyMissionsColors.pendingIconBackground,
                borderRadius: BorderRadius.circular(_tileRadius),
              ),
              child: Icon(
                mission.icon,
                size: _glyphSize,
                color: completed ? WeeklyMissionsColors.gold : AppDesign.red,
              ),
            ),
            const SizedBox(width: _spacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission.title,
                    style: context.text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mission.howTo(l),
                    style: context.text.bodySmall?.copyWith(
                      color: AppDesign.muted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: MissionsProgressBar(
                          progress: mission.progress,
                          color: completed ? WeeklyMissionsColors.green : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l.missionsProgressRatio(
                          mission.shownCount,
                          mission.targetCount,
                        ),
                        style: context.text.labelMedium?.copyWith(
                          color: AppDesign.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: _spacing),
            _Trailing(mission: mission),
          ],
        ),
      ),
    );
  }
}

class _Trailing extends StatelessWidget {
  const _Trailing({required this.mission});

  final WeeklyMission mission;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final label = mission.status.label(l);
    switch (mission.status) {
      case MissionStatus.completed:
        return Icon(
          Symbols.check_circle,
          fill: 1,
          size: _checkSize,
          color: WeeklyMissionsColors.green,
          semanticLabel: label,
        );
      case MissionStatus.expired:
        return Text(
          label ?? '',
          style: context.text.labelSmall?.copyWith(color: AppDesign.muted),
        );
      case MissionStatus.inProgress:
        return DecoratedBox(
          decoration: BoxDecoration(
            color: WeeklyMissionsColors.pointsBadge,
            borderRadius: BorderRadius.circular(_chipRadius),
          ),
          child: Padding(
            padding: _chipPadding,
            child: Text(
              l.missionsXpReward(mission.xpReward),
              style: context.text.labelMedium?.copyWith(
                color: WeeklyMissionsColors.gold,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
    }
  }
}
