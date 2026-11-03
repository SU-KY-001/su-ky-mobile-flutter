import 'package:flutter/material.dart';
import 'package:su_ky_mobile/features/weekly_missions/domain/mission.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/mission_l10n.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/missions_panel.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

/// Bottom sheet that lets the user mark a pending demo mission as done.
class MissionProgressSheet extends StatelessWidget {
  const MissionProgressSheet({
    super.key,
    required this.mission,
    required this.onComplete,
  });

  final Mission mission;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mission.title(l),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppDesign.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mission.subtitle(l),
              style: const TextStyle(fontSize: 13, color: AppDesign.muted),
            ),
            const SizedBox(height: 18),
            Text(
              mission.detail(l),
              style: const TextStyle(
                color: AppDesign.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            MissionsProgressBar(progress: mission.progress),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppDesign.red,
                  padding: const EdgeInsets.all(15),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  onComplete();
                },
                child: Text(l.missionsTryComplete),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
