import 'package:flutter/material.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/missions_panel.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_missions_colors.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_missions_view_model.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

class WeeklyIntroCard extends StatelessWidget {
  const WeeklyIntroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return MissionsPanel(
      color: WeeklyMissionsColors.introPanel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppDesign.gap,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                l.missionsIntroEyebrow,
                style: const TextStyle(
                  color: AppDesign.red,
                  fontSize: 10,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                l.missionsIntroWeek,
                style: TextStyle(
                  color: AppDesign.muted.withValues(alpha: .9),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l.missionsIntroTitle,
            style: const TextStyle(
              color: AppDesign.ink,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l.missionsIntroBody,
            style: const TextStyle(
              fontSize: 12,
              color: AppDesign.muted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class WeeklyProgressCard extends StatelessWidget {
  const WeeklyProgressCard({super.key, required this.state});

  final WeeklyMissionsState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return MissionsPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppDesign.gap,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l.missionsProgressTitle,
                style: const TextStyle(
                  color: AppDesign.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppDesign.red,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  l.missionsProgressPercent(
                    (state.weeklyProgress * 100).round(),
                  ),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            l.missionsProgressCount(
              state.completedCount,
              state.missions.length,
            ),
            style: const TextStyle(
              fontSize: 24,
              color: AppDesign.red,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          MissionsProgressBar(progress: state.weeklyProgress, height: 8),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  icon: Icons.stars_rounded,
                  value: '${state.totalPoints}',
                  label: l.missionsStatPoints,
                  background: WeeklyMissionsColors.pointsStatBackground,
                  foreground: WeeklyMissionsColors.gold,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _StatBox(
                  icon: Icons.local_fire_department_outlined,
                  value: l.missionsStatStreakValue(state.streakDays),
                  label: l.missionsStatStreak,
                  background: WeeklyMissionsColors.streakStatBackground,
                  foreground: AppDesign.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.icon,
    required this.value,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, color: foreground, size: 22),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppDesign.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 9, color: AppDesign.muted),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
