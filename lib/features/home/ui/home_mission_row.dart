import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/missions/missions_providers.dart';

const _rowHeight = 56.0;
const _barHeight = 6.0;
const _gap = 12.0;

/// Duolingo "Daily quests" style slim row; hidden for guests and while
/// missions are loading or unavailable.
class HomeMissionRow extends ConsumerWidget {
  const HomeMissionRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missions = ref.watch(weeklyMissionsProvider).value;
    if (missions == null || missions.items.isEmpty) {
      return const SizedBox.shrink();
    }
    final l = AppLocalizations.of(context);
    final done = missions.completedCount;
    final total = missions.items.length;
    return InkWell(
      onTap: () => context.push(AppRoutes.weeklyMissions),
      child: SizedBox(
        height: _rowHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesign.pagePadding,
          ),
          child: Row(
            children: [
              Icon(Icons.emoji_events_outlined, color: context.accent),
              const SizedBox(width: _gap),
              Text(
                l.weeklyMissions,
                style: context.text.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: _gap),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_barHeight),
                  child: LinearProgressIndicator(
                    value: done / total,
                    minHeight: _barHeight,
                  ),
                ),
              ),
              const SizedBox(width: _gap),
              Text(
                l.missionsProgressCount(done, total),
                style: context.text.labelLarge,
              ),
              const Icon(Icons.chevron_right, color: AppDesign.muted),
            ],
          ),
        ),
      ),
    );
  }
}
