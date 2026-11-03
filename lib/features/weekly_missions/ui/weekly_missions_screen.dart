import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:su_ky_mobile/features/weekly_missions/ui/mission_tile.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/missions_panel.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_missions_colors.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_missions_header.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_missions_summary.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/missions/domain/weekly_missions.dart';
import 'package:su_ky_mobile/shared/missions/missions_providers.dart';
import 'package:su_ky_mobile/shared/widgets/catalog_states.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

class WeeklyMissionsScreen extends ConsumerWidget {
  const WeeklyMissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missions = ref.watch(weeklyMissionsProvider);
    return AppPage(
      child: ListView(
        padding: const EdgeInsets.all(AppDesign.pagePadding),
        children: [
          const WeeklyMissionsHeader(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppDesign.gap),
            child: Divider(),
          ),
          missions.when(
            loading: () => const CatalogLoading(),
            error: (error, _) => CatalogError(
              error: error,
              onRetry: () => ref.invalidate(weeklyMissionsProvider),
            ),
            data: (value) => _MissionsBody(value: value),
          ),
        ],
      ),
    );
  }
}

class _MissionsBody extends StatelessWidget {
  const _MissionsBody({required this.value});

  final WeeklyMissions? value;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final missions = value;
    if (missions == null) {
      return CatalogEmpty(
        title: l.missionsGuestTitle,
        message: l.missionsGuestMessage,
      );
    }
    if (missions.items.isEmpty) {
      return CatalogEmpty(
        title: l.missionsEmptyTitle,
        message: l.missionsEmptyMessage,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WeeklySummaryCard(missions: missions),
        const SizedBox(height: AppDesign.pagePadding),
        Text(
          l.missionsListTitle,
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppDesign.gap),
        MissionsPanel(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
          child: Column(
            children: [
              for (var index = 0; index < missions.items.length; index++) ...[
                MissionTile(mission: missions.items[index]),
                if (index < missions.items.length - 1)
                  const Divider(height: 1, color: WeeklyMissionsColors.divider),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
