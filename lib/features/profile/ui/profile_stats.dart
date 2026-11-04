import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/missions/missions_providers.dart';

const _cardPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 14);

/// Summary block above the groups: XP and completed missions on a soft tinted
/// surface, so it reads as a different level than the navigation rows.
class ProfileStats extends ConsumerWidget {
  const ProfileStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missions = ref.watch(weeklyMissionsProvider).value;
    if (missions == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    return Container(
      padding: _cardPadding,
      decoration: BoxDecoration(
        color: AppDesign.tint,
        borderRadius: BorderRadius.circular(AppDesign.radius),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Stat(value: missions.totalXp, label: l.profileStatXp),
          ),
          const SizedBox(
            height: AppDesign.tapTarget,
            child: VerticalDivider(width: AppDesign.gap * 2),
          ),
          Expanded(
            child: _Stat(
              value: missions.completedCount,
              label: l.profileStatMissions,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '$value',
        style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
      Text(
        label,
        style: context.text.bodySmall?.copyWith(color: AppDesign.muted),
      ),
    ],
  );
}
