import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

import 'mission_widgets.dart';

class MissionDetailScreen extends ConsumerWidget {
  static const recommendedEpisode = 2;
  const MissionDetailScreen({
    super.key,
    required this.onBack,
    required this.onHonours,
    required this.onProfile,
    required this.onListen,
  });
  final VoidCallback onBack, onHonours, onProfile, onListen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return AppPage(
      bottom: MissionFooter(
        label: l.missionContinue,
        onPressed: onListen,
        footnote: l.missionRewardFootnote,
      ),
      child: ListView(
        padding: const EdgeInsets.all(AppDesign.pagePadding),
        children: [
          MissionHeader(
            title: l.missionDetailTitle,
            onBack: onBack,
            onHonours: onHonours,
            onProfile: onProfile,
          ),
          MissionDesign.gap,
          Surface(
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
                      child: Icon(
                        Icons.headphones_outlined,
                        color: AppDesign.red,
                      ),
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
          ),
          MissionDesign.sectionGap,
          MissionSectionHeading(
            title: l.missionConditions,
            caption: l.missionRulesLabel,
          ),
          _Condition(
            title: l.missionStepOne,
            description: l.missionStepOneDescription,
            status: l.missionDone,
            icon: Icons.check,
            color: MissionDesign.green,
          ),
          _Condition(
            title: l.missionStepTwo,
            description: l.missionStepTwoDescription,
            status: l.missionActive,
            number: l.missionStepTwoNumber,
            color: AppDesign.red,
          ),
          _Condition(
            title: l.missionStepThree,
            description: l.missionStepThreeDescription,
            status: l.missionLocked,
            number: l.missionStepThreeNumber,
            color: AppDesign.muted,
          ),
          MissionDesign.sectionGap,
          MissionSectionHeading(
            title: l.missionNext,
            caption: l.missionRecommended,
          ),
          Surface(
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
          ),
          MissionDesign.gap,
          Surface(
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
                      Text(
                        l.missionSealDescription,
                        style: context.text.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          MissionDesign.gap,
          Text(
            l.missionSampleNotice,
            style: context.text.labelSmall?.copyWith(color: AppDesign.muted),
          ),
        ],
      ),
    );
  }
}

class _Condition extends StatelessWidget {
  const _Condition({
    required this.title,
    required this.description,
    required this.status,
    required this.color,
    this.icon,
    this.number,
  });
  final String title, description, status;
  final String? number;
  final Color color;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Surface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color,
            child: icon != null
                ? Icon(icon, size: 18, color: Colors.white)
                : Text(
                    number!,
                    style: context.text.labelSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: context.text.bodySmall?.copyWith(
                    color: AppDesign.muted,
                  ),
                ),
                MissionDesign.smallGap,
                Text(
                  status,
                  style: context.text.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
