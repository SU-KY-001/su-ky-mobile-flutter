import 'package:flutter/material.dart';

import 'package:su_ky_mobile/features/weekly_missions/ui/mission_widgets.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/missions_panel.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_missions_colors.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/missions/domain/weekly_missions.dart';

const _boxRadius = 12.0;
const _boxPadding = EdgeInsets.symmetric(horizontal: 11, vertical: 10);
const _iconSize = 22.0;
const _gap = 9.0;
const _weekEndIcon = 16.0;

class WeeklySummaryCard extends StatelessWidget {
  const WeeklySummaryCard({super.key, required this.missions});

  final WeeklyMissions missions;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return MissionsPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryBox(
                  icon: Icons.stars_rounded,
                  label: l.missionsTotalXp,
                  value: '${missions.totalXp}',
                  background: WeeklyMissionsColors.pointsStatBackground,
                  foreground: MissionDesign.gold,
                ),
              ),
              const SizedBox(width: _gap),
              Expanded(
                child: _SummaryBox(
                  icon: Icons.task_alt,
                  label: l.missionsCompletedLabel,
                  value: l.missionsProgressRatio(
                    missions.completedCount,
                    missions.items.length,
                  ),
                  background: MissionDesign.paleGreen,
                  foreground: MissionDesign.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.event_outlined,
                size: _weekEndIcon,
                color: AppDesign.muted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l.missionsWeekEnd(missions.weekEnd.toLocal()),
                  style: context.text.bodySmall?.copyWith(
                    color: AppDesign.muted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  const _SummaryBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
    padding: _boxPadding,
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(_boxRadius),
    ),
    child: Row(
      children: [
        Icon(icon, color: foreground, size: _iconSize),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: context.text.titleSmall?.copyWith(
                  color: AppDesign.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: context.text.labelSmall?.copyWith(
                  color: AppDesign.muted,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
