import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/mission_widgets.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_missions_colors.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

class WeeklyMissionsHeader extends StatelessWidget {
  const WeeklyMissionsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.popOrGo(AppRoutes.home),
          child: Container(
            width: 37,
            height: 37,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: WeeklyMissionsColors.backButton,
            ),
            child: const Icon(Icons.arrow_back, size: 18, color: AppDesign.ink),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                l.missionsEyebrow,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: WeeklyMissionsColors.gold,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                l.missionsHeaderTitle,
                textAlign: TextAlign.center,
                style: MissionDesign.heading(
                  context,
                  size: MissionDesign.sectionSize,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => context.go(AppRoutes.profile),
          child: const CircleAvatar(
            radius: 17,
            backgroundColor: AppDesign.red,
            child: Icon(Icons.person_outline, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }
}
