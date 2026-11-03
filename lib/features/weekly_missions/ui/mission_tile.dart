import 'package:flutter/material.dart';
import 'package:su_ky_mobile/features/weekly_missions/domain/mission.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/mission_l10n.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/missions_panel.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_missions_colors.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

class MissionTile extends StatelessWidget {
  const MissionTile({super.key, required this.mission, required this.onTap});

  final Mission mission;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final completed = mission.completed;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: completed
                    ? WeeklyMissionsColors.doneIconBackground
                    : WeeklyMissionsColors.pendingIconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                mission.icon,
                size: 18,
                color: completed ? WeeklyMissionsColors.gold : AppDesign.red,
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
                          mission.title(l),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppDesign.ink,
                            height: 1.35,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: WeeklyMissionsColors.pointsBadge,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          l.missionsPoints(mission.points),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: WeeklyMissionsColors.gold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    mission.subtitle(l),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppDesign.muted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          mission.detail(l),
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppDesign.muted,
                          ),
                        ),
                      ),
                      if (completed) ...[
                        const Icon(
                          Icons.check_circle,
                          size: 12,
                          color: WeeklyMissionsColors.green,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          l.missionsCompleted,
                          style: const TextStyle(
                            color: WeeklyMissionsColors.green,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ] else
                        Text(
                          '${(mission.progress * 100).round()}%',
                          style: const TextStyle(
                            color: AppDesign.red,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
                  if (!completed) ...[
                    const SizedBox(height: 7),
                    MissionsProgressBar(progress: mission.progress, height: 5),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: 28,
                        child: ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppDesign.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            l.missionsContinueListening,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
