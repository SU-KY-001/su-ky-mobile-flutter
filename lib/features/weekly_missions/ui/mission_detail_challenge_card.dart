import 'package:flutter/material.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/mission_widgets.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

class MissionDetailChallengeCard extends StatelessWidget {
  const MissionDetailChallengeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppDesign.gap,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                l.missionChallenge,
                style: context.text.labelSmall?.copyWith(
                  color: AppDesign.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: MissionDesign.paleGold,
                  borderRadius: BorderRadius.circular(AppDesign.radius),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  child: Text(
                    l.missionPoints,
                    style: context.text.labelSmall?.copyWith(
                      color: MissionDesign.gold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          MissionDesign.gap,
          Text(l.missionJourney, style: MissionDesign.heading(context)),
          MissionDesign.smallGap,
          Text(
            l.missionJourneyDescription,
            style: context.text.bodyMedium?.copyWith(
              color: AppDesign.muted,
              height: 1.6,
            ),
          ),
          MissionDesign.sectionGap,
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppDesign.tint,
                child: Icon(Icons.headphones_outlined, color: AppDesign.red),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.missionChronicle,
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l.missionChronicleSubtitle,
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          MissionDesign.gap,
          Container(
            padding: MissionDesign.contentPadding,
            decoration: BoxDecoration(
              color: AppDesign.canvas,
              borderRadius: BorderRadius.circular(AppDesign.radius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppDesign.gap,
                  runSpacing: 8,
                  children: [
                    Text(
                      l.missionProgressLabel,
                      style: context.text.labelMedium,
                    ),
                    Text(
                      l.missionProgressValue,
                      style: context.text.bodySmall?.copyWith(
                        color: AppDesign.red,
                      ),
                    ),
                  ],
                ),
                MissionDesign.smallGap,
                const LinearProgressIndicator(
                  value: MissionDesign.progress,
                  color: AppDesign.red,
                  backgroundColor: AppDesign.line,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppDesign.radius),
                  ),
                ),
                MissionDesign.smallGap,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: MissionDesign.gold,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l.missionProgressHint,
                        style: context.text.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
