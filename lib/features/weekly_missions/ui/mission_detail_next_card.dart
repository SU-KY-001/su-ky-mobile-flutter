import 'package:flutter/material.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/mission_widgets.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

class MissionDetailNextCard extends StatelessWidget {
  const MissionDetailNextCard({super.key, required this.onListen});

  final VoidCallback onListen;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CoverArt(width: 72, height: 88),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.missionEpisodeMeta,
                      style: context.text.labelSmall?.copyWith(
                        color: AppDesign.red,
                      ),
                    ),
                    MissionDesign.smallGap,
                    Text(
                      l.missionEpisodeTitle,
                      style: MissionDesign.heading(
                        context,
                        size: MissionDesign.sectionSize,
                      ),
                    ),
                    MissionDesign.smallGap,
                    Text(
                      l.missionEpisodeDescription,
                      style: context.text.bodySmall?.copyWith(
                        color: AppDesign.muted,
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
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(l.missionNarrator, style: context.text.bodySmall),
              FilledButton.icon(
                onPressed: onListen,
                icon: const Icon(Icons.play_arrow),
                label: Text(l.missionListen),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MissionDetailSealCard extends StatelessWidget {
  const MissionDetailSealCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Surface(
      selected: true,
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: MissionDesign.paleGold,
            child: Icon(
              Icons.military_tech_outlined,
              color: MissionDesign.gold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.missionSeal,
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(l.missionSealDescription, style: context.text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
