import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/honours_badge_card.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/honours_medallion.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/honours_milestone.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/honours_statistics.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/mission_widgets.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

class HonoursScreen extends ConsumerWidget {
  const HonoursScreen({super.key});

  void _back(BuildContext context) =>
      MissionDesign.goBack(context, AppRoutes.weeklyMissions);

  void _showCollection(BuildContext context) {
    final l = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDesign.pagePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.honoursCollection, style: MissionDesign.heading(context)),
              MissionDesign.gap,
              const HonoursBadgeCard(),
              MissionDesign.gap,
              Text(l.missionSampleNotice, style: context.text.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return AppPage(
      bottom: MissionFooter(
        label: l.honoursDiscover,
        onPressed: () => context.go(AppRoutes.home),
        secondaryLabel: l.honoursCollection,
        onSecondary: () => _showCollection(context),
      ),
      child: ListView(
        padding: const EdgeInsets.all(AppDesign.pagePadding),
        children: [
          MissionHeader(
            title: l.honoursTitle,
            onBack: () => _back(context),
            onHonours: () => MissionDesign.showPreviewNotice(context),
            onProfile: () => context.go(AppRoutes.profile),
          ),
          MissionDesign.gap,
          Row(
            children: [
              IconButton.filledTonal(
                tooltip: l.close,
                onPressed: () => _back(context),
                icon: const Icon(Icons.close),
              ),
              Expanded(
                child: Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: MissionDesign.paleGold,
                      borderRadius: BorderRadius.circular(AppDesign.radius),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Text(
                        l.honoursWeek,
                        textAlign: TextAlign.center,
                        style: context.text.labelSmall?.copyWith(
                          color: MissionDesign.gold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton.filledTonal(
                tooltip: l.share,
                onPressed: () => MissionDesign.showPreviewNotice(context),
                icon: const Icon(Icons.share_outlined),
              ),
            ],
          ),
          MissionDesign.sectionGap,
          const HonoursMedallion(),
          MissionDesign.sectionGap,
          Text(
            l.honoursCongratulations,
            textAlign: TextAlign.center,
            style: MissionDesign.heading(context)
                .copyWith(color: AppDesign.red),
          ),
          MissionDesign.smallGap,
          Text(
            l.honoursDescription,
            textAlign: TextAlign.center,
            style: context.text.bodyMedium?.copyWith(
              color: AppDesign.muted,
              height: 1.7,
            ),
          ),
          MissionDesign.sectionGap,
          const HonoursStatistics(),
          MissionDesign.sectionGap,
          const HonoursBadgeCard(),
          MissionDesign.sectionGap,
          MissionSectionHeading(
            title: l.honoursMilestones,
            caption: l.honoursWeekDetail,
          ),
          HonoursMilestone(
            icon: Icons.album_outlined,
            title: l.honoursEpisodes,
            description: l.honoursEpisodesDescription,
            status: l.honoursEpisodesStatus,
            color: AppDesign.red,
          ),
          HonoursMilestone(
            icon: Icons.headphones_outlined,
            title: l.honoursMinutes,
            description: l.honoursMinutesDescription,
            status: l.honoursMinutesStatus,
            color: MissionDesign.gold,
          ),
          HonoursMilestone(
            icon: Icons.history_edu_outlined,
            title: l.honoursQuiz,
            description: l.honoursQuizDescription,
            status: l.honoursQuizStatus,
            color: MissionDesign.green,
          ),
          MissionDesign.gap,
          Surface(
            selected: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.menu_book_outlined, color: MissionDesign.gold),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.honoursQuote,
                    style: context.text.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                    ),
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
