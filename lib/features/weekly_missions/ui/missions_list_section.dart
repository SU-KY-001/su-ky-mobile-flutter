import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/features/weekly_missions/domain/mission.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/mission_progress_sheet.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/mission_tile.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/mission_widgets.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/missions_panel.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_missions_colors.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_missions_view_model.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

/// "Your missions" title row plus the card listing every mission.
class MissionsListSection extends ConsumerWidget {
  const MissionsListSection({super.key});

  void _showMessage(BuildContext context, String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: MissionDesign.snackBarDuration,
        ),
      );

  void _onMissionTap(BuildContext context, WidgetRef ref, Mission mission) {
    final l = AppLocalizations.of(context);
    if (mission.opensDetail) {
      context.push(AppRoutes.missionDetail);
      return;
    }
    if (mission.completed) {
      _showMessage(context, l.missionsAlreadyDone);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppDesign.canvas,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => MissionProgressSheet(
        mission: mission,
        onComplete: () {
          ref
              .read(weeklyMissionsViewModelProvider.notifier)
              .complete(mission.kind);
          _showMessage(context, l.missionsDemoDone);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(weeklyMissionsViewModelProvider);
    final viewModel = ref.read(weeklyMissionsViewModelProvider.notifier);
    final visible = state.showAllTasks
        ? state.missions
        : state.missions.take(MissionDesign.collapsedMissionCount).toList();

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 7,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l.missionsListTitle,
                style: const TextStyle(
                  color: AppDesign.ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: WeeklyMissionsColors.countBadge,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '${state.missions.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppDesign.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  viewModel.toggleHistory();
                  if (!state.showHistory) {
                    _showMessage(
                      context,
                      l.missionsHistoryMessage(state.completedCount),
                    );
                  }
                },
                child: Text(
                  l.missionsHistory,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppDesign.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDesign.gap),
        MissionsPanel(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
          child: Column(
            children: [
              for (var i = 0; i < visible.length; i++) ...[
                MissionTile(
                  mission: visible[i],
                  onTap: () => _onMissionTap(context, ref, visible[i]),
                ),
                if (i < visible.length - 1)
                  const Divider(height: 1, color: WeeklyMissionsColors.divider),
              ],
              if (!state.showAllTasks)
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () => viewModel.setShowAllTasks(true),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppDesign.ink,
                      side: const BorderSide(
                        color: WeeklyMissionsColors.outline,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(
                      l.missionsViewAll,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: () => viewModel.setShowAllTasks(false),
                  child: Text(l.missionsCollapse),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
