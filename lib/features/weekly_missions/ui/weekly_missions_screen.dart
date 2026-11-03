import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/missions_list_section.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_calendar_card.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_missions_header.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_missions_summary.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_missions_view_model.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_reward_cards.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

class WeeklyMissionsScreen extends ConsumerWidget {
  const WeeklyMissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weeklyMissionsViewModelProvider);
    return AppPage(
      bottom: MainNavigation(
        index: 0,
        onDiscover: () => context.go(AppRoutes.home),
        onSearch: () => context.go(AppRoutes.search),
        onProfile: () => context.push(AppRoutes.login),
      ),
      child: ListView(
        padding: const EdgeInsets.all(AppDesign.pagePadding),
        children: [
          const WeeklyMissionsHeader(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppDesign.gap),
            child: Divider(),
          ),
          const WeeklyMissionsBackRow(),
          const SizedBox(height: AppDesign.gap),
          const WeeklyIntroCard(),
          const SizedBox(height: AppDesign.gap),
          WeeklyProgressCard(state: state),
          const SizedBox(height: AppDesign.gap),
          WeeklyCalendarCard(
            weekDates: state.weekDates,
            checkedInDays: state.checkedInDays,
            selectedDay: state.selectedDay,
            onSelectDay: ref
                .read(weeklyMissionsViewModelProvider.notifier)
                .selectDay,
          ),
          const SizedBox(height: AppDesign.pagePadding),
          const MissionsListSection(),
          const SizedBox(height: AppDesign.gap),
          const WeeklyRewardCard(),
          const SizedBox(height: AppDesign.gap),
          const WeeklyQuoteCard(),
        ],
      ),
    );
  }
}
