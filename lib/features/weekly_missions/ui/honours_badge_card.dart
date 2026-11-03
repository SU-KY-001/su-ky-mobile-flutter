import 'package:flutter/material.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/mission_widgets.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

class HonoursBadgeCard extends StatelessWidget {
  const HonoursBadgeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: MissionDesign.contentPadding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDesign.radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, MissionDesign.paleGold],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDesign.radius),
                  boxShadow: [
                    BoxShadow(
                      color: MissionDesign.gold.withValues(alpha: .12),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_stories,
                  color: MissionDesign.gold,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.honoursBadgeNew,
                      style: context.text.labelSmall?.copyWith(
                        color: MissionDesign.gold,
                      ),
                    ),
                    MissionDesign.smallGap,
                    Text(
                      l.honoursBadgeTitle,
                      style: MissionDesign.heading(
                        context,
                        size: MissionDesign.sectionSize,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.honoursBadgeDescription,
                      style: context.text.bodySmall?.copyWith(
                        color: AppDesign.muted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          MissionDesign.gap,
          Wrap(
            spacing: AppDesign.gap,
            runSpacing: 8,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: MissionDesign.paleGreen,
                  borderRadius: BorderRadius.circular(AppDesign.radius),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    l.honoursBadgePreview,
                    style: context.text.labelSmall?.copyWith(
                      color: MissionDesign.green,
                    ),
                  ),
                ),
              ),
              Text(
                l.honoursBadgeLevel,
                style: context.text.labelSmall?.copyWith(
                  color: MissionDesign.gold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
