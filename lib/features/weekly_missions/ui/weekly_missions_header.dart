import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/mission_widgets.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_missions_colors.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

/// Brand bar: logo, title, honours shortcut and profile avatar.
class WeeklyMissionsHeader extends StatelessWidget {
  const WeeklyMissionsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        Container(
          width: 29,
          height: 29,
          decoration: const BoxDecoration(
            color: AppDesign.red,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.auto_stories_outlined,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            l.missionsHeaderTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppDesign.red,
              fontFamily: 'Inter',
            ),
          ),
        ),
        IconButton(
          tooltip: l.honoursTitle,
          onPressed: () => context.push(AppRoutes.honours),
          icon: const Icon(
            Icons.military_tech_outlined,
            color: WeeklyMissionsColors.gold,
            size: 21,
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

class WeeklyMissionsBackRow extends StatelessWidget {
  const WeeklyMissionsBackRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        GestureDetector(
          onTap: () => MissionDesign.goBack(context, AppRoutes.home),
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
                style: const TextStyle(
                  fontSize: 17,
                  color: AppDesign.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 37,
          height: 37,
          decoration: const BoxDecoration(
            color: WeeklyMissionsColors.trophyBackground,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.emoji_events_outlined,
            size: 19,
            color: WeeklyMissionsColors.gold,
          ),
        ),
      ],
    );
  }
}
