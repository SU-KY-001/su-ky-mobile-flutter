import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/missions/domain/weekly_missions.dart';
import 'package:su_ky_mobile/shared/missions/missions_providers.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

const _badgeRadius = 18.0;
const _badgeIconSize = 22.0;
const _chevronSize = 20.0;
const _skeletonBadge = 36.0;
const _skeletonWidth = 140.0;
const _skeletonLine = 14.0;
const _skeletonRadius = 8.0;
const _skeletonStackGap = 6.0;

class ProfileXpCard extends ConsumerWidget {
  const ProfileXpCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missions = ref.watch(weeklyMissionsProvider);
    return missions.when(
      loading: () => const _XpSkeleton(),
      error: (_, _) => const SizedBox.shrink(),
      data: (value) =>
          value == null ? const SizedBox.shrink() : _XpCard(missions: value),
    );
  }
}

class _XpCard extends StatelessWidget {
  const _XpCard({required this.missions});

  final WeeklyMissions missions;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Surface(
      child: InkWell(
        onTap: () => context.push(AppRoutes.weeklyMissions),
        child: Row(
          children: [
            CircleAvatar(
              radius: _badgeRadius,
              backgroundColor: AppDesign.tint,
              child: Icon(
                Icons.stars_rounded,
                size: _badgeIconSize,
                color: context.accent,
              ),
            ),
            const SizedBox(width: AppDesign.gap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.profileXpTotal(missions.totalXp),
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    l.profileMissionsDone(missions.completedCount),
                    style: context.text.bodySmall?.copyWith(
                      color: AppDesign.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: _chevronSize,
              color: AppDesign.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _XpSkeleton extends StatelessWidget {
  const _XpSkeleton();

  @override
  Widget build(BuildContext context) => const Surface(
    child: Row(
      children: [
        _SkeletonBar(width: _skeletonBadge, height: _skeletonBadge),
        SizedBox(width: AppDesign.gap),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkeletonBar(width: _skeletonWidth, height: _skeletonLine),
            SizedBox(height: _skeletonStackGap),
            _SkeletonBar(width: _skeletonWidth, height: _skeletonLine),
          ],
        ),
      ],
    ),
  );
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: AppDesign.line,
      borderRadius: BorderRadius.circular(_skeletonRadius),
    ),
  );
}
