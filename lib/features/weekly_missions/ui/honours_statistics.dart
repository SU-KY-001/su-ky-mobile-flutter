import 'package:flutter/material.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/mission_widgets.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

class HonoursStatistics extends StatelessWidget {
  const HonoursStatistics({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Surface(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _Statistic(
                value: l.honoursTasksValue,
                label: l.honoursTasks,
                icon: Icons.task_alt,
                color: AppDesign.red,
              ),
            ),
            const VerticalDivider(width: 16),
            Expanded(
              child: _Statistic(
                value: l.honoursPointsValue,
                label: l.honoursPoints,
                icon: Icons.token,
                color: MissionDesign.gold,
              ),
            ),
            const VerticalDivider(width: 16),
            Expanded(
              child: _Statistic(
                value: l.honoursDaysValue,
                label: l.honoursDays,
                icon: Icons.local_fire_department,
                color: MissionDesign.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Statistic extends StatelessWidget {
  const _Statistic({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value, label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      CircleAvatar(
        radius: 16,
        backgroundColor: color.withValues(alpha: .1),
        child: Icon(icon, color: color, size: 18),
      ),
      MissionDesign.smallGap,
      Text(
        value,
        textAlign: TextAlign.center,
        style: MissionDesign.heading(context).copyWith(color: color),
      ),
      Text(label, textAlign: TextAlign.center, style: context.text.labelSmall),
    ],
  );
}
