import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/mission_condition.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/mission_detail_challenge_card.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/mission_detail_next_card.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/mission_widgets.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

class MissionDetailScreen extends ConsumerWidget {
  const MissionDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    void listen() => context.go(AppRoutes.podcast);
    return AppPage(
      bottom: MissionFooter(
        label: l.missionContinue,
        onPressed: listen,
        footnote: l.missionRewardFootnote,
      ),
      child: ListView(
        padding: const EdgeInsets.all(AppDesign.pagePadding),
        children: [
          MissionHeader(
            title: l.missionDetailTitle,
            onBack: () =>
                MissionDesign.goBack(context, AppRoutes.weeklyMissions),
            onHonours: () => context.push(AppRoutes.honours),
            onProfile: () => context.go(AppRoutes.profile),
          ),
          MissionDesign.gap,
          const MissionDetailChallengeCard(),
          MissionDesign.sectionGap,
          MissionSectionHeading(
            title: l.missionConditions,
            caption: l.missionRulesLabel,
          ),
          MissionCondition(
            title: l.missionStepOne,
            description: l.missionStepOneDescription,
            status: l.missionDone,
            icon: Icons.check,
            color: MissionDesign.green,
          ),
          MissionCondition(
            title: l.missionStepTwo,
            description: l.missionStepTwoDescription,
            status: l.missionActive,
            number: l.missionStepTwoNumber,
            color: AppDesign.red,
          ),
          MissionCondition(
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
          MissionDetailNextCard(onListen: listen),
          MissionDesign.gap,
          const MissionDetailSealCard(),
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
