import 'package:flutter/material.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/missions_panel.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_missions_colors.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

class WeeklyRewardCard extends StatelessWidget {
  const WeeklyRewardCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return MissionsPanel(
      color: WeeklyMissionsColors.rewardPanel,
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppDesign.red,
              border: Border.all(color: WeeklyMissionsColors.gold, width: 4),
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: WeeklyMissionsColors.rewardIcon,
              size: 35,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.missionsRewardEyebrow,
                  style: const TextStyle(
                    fontSize: 10,
                    color: WeeklyMissionsColors.gold,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.missionsRewardTitle,
                  style: const TextStyle(
                    color: AppDesign.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  l.missionsRewardBody,
                  style: const TextStyle(
                    color: AppDesign.muted,
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WeeklyQuoteCard extends StatelessWidget {
  const WeeklyQuoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return MissionsPanel(
      color: WeeklyMissionsColors.quotePanel,
      child: Column(
        children: [
          const Text(
            '❞',
            style: TextStyle(
              color: AppDesign.red,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            l.missionsQuote,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: AppDesign.ink,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.missionsQuoteSource,
            style: const TextStyle(
              color: WeeklyMissionsColors.gold,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
