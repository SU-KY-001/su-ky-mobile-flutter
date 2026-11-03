import 'package:flutter/material.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/mission_widgets.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/missions_panel.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_missions_colors.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

class WeeklyCalendarCard extends StatelessWidget {
  const WeeklyCalendarCard({
    super.key,
    required this.weekDates,
    required this.checkedInDays,
    required this.selectedDay,
    required this.onSelectDay,
  });

  final List<int> weekDates;
  final int checkedInDays;
  final int selectedDay;
  final ValueChanged<int> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final days = [
      l.missionsDayMon,
      l.missionsDayTue,
      l.missionsDayWed,
      l.missionsDayThu,
      l.missionsDayFri,
      l.missionsDaySat,
      l.missionsDaySun,
    ];
    return MissionsPanel(
      padding: const EdgeInsets.all(13),
      child: Column(
        children: [
          Wrap(
            spacing: AppDesign.gap,
            runSpacing: 4,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                l.missionsCalendarTitle,
                style: const TextStyle(
                  color: AppDesign.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                l.missionsCalendarToday,
                style: const TextStyle(
                  color: WeeklyMissionsColors.gold,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var index = 0; index < days.length; index++)
                _DayColumn(
                  label: days[index],
                  date: '${weekDates[index]}',
                  active: index == selectedDay,
                  completed: index < checkedInDays,
                  onTap: () => onSelectDay(index),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.label,
    required this.date,
    required this.active,
    required this.completed,
    required this.onTap,
  });

  final String label;
  final String date;
  final bool active;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppDesign.muted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        AnimatedContainer(
          duration: MissionDesign.dayAnimationDuration,
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? AppDesign.red
                : completed
                ? WeeklyMissionsColors.dayDone
                : WeeklyMissionsColors.dayPending,
          ),
          alignment: Alignment.center,
          child: Text(
            date,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: active || completed ? Colors.white : AppDesign.muted,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Icon(
          completed ? Icons.check_circle : Icons.circle_outlined,
          size: 11,
          color: completed
              ? AppDesign.red
              : WeeklyMissionsColors.dayCheckPending,
        ),
      ],
    ),
  );
}
