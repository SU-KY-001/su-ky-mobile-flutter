import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

import 'mission_widgets.dart';

class HonoursScreen extends ConsumerWidget {
  const HonoursScreen({
    super.key,
    required this.onBack,
    required this.onDiscover,
    required this.onProfile,
  });
  final VoidCallback onBack, onDiscover, onProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return AppPage(
      bottom: MissionFooter(
        label: l.honoursDiscover,
        onPressed: onDiscover,
        secondaryLabel: l.honoursCollection,
        onSecondary: () => showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          isScrollControlled: true,
          builder: (_) => SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDesign.pagePadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l.honoursCollection,
                    style: MissionDesign.heading(context),
                  ),
                  MissionDesign.gap,
                  const _BadgeCard(),
                  MissionDesign.gap,
                  Text(l.missionSampleNotice, style: context.text.bodySmall),
                ],
              ),
            ),
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(AppDesign.pagePadding),
        children: [
          MissionHeader(
            title: l.honoursTitle,
            onBack: onBack,
            onHonours: () => MissionDesign.showPreviewNotice(context),
            onProfile: onProfile,
          ),
          MissionDesign.gap,
          Row(
            children: [
              IconButton.filledTonal(
                tooltip: l.close,
                onPressed: onBack,
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
          const _Medallion(),
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
          Surface(
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _Statistic(
                      value: l.honoursTasksValue,
                      label: l.honoursTasks,
                      icon: Icons.task_alt,
                      color: AppDesign.red,
                    ),
                  ),
                  const VerticalDivider(width: 16),
                  Expanded(
                    child: _Statistic(
                      value: l.honoursPointsValue,
                      label: l.honoursPoints,
                      icon: Icons.token,
                      color: MissionDesign.gold,
                    ),
                  ),
                  const VerticalDivider(width: 16),
                  Expanded(
                    child: _Statistic(
                      value: l.honoursDaysValue,
                      label: l.honoursDays,
                      icon: Icons.local_fire_department,
                      color: MissionDesign.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          MissionDesign.sectionGap,
          const _BadgeCard(),
          MissionDesign.sectionGap,
          MissionSectionHeading(
            title: l.honoursMilestones,
            caption: l.honoursWeekDetail,
          ),
          _Milestone(
            icon: Icons.album_outlined,
            title: l.honoursEpisodes,
            description: l.honoursEpisodesDescription,
            status: l.honoursEpisodesStatus,
            color: AppDesign.red,
          ),
          _Milestone(
            icon: Icons.headphones_outlined,
            title: l.honoursMinutes,
            description: l.honoursMinutesDescription,
            status: l.honoursMinutesStatus,
            color: MissionDesign.gold,
          ),
          _Milestone(
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

class _Medallion extends StatelessWidget {
  const _Medallion();
  @override
  Widget build(BuildContext context) => Semantics(
    label: AppLocalizations.of(context).honoursFeat,
    child: Column(
      children: [
        Container(
          width: MissionDesign.badgeSize,
          height: MissionDesign.badgeSize,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: MissionDesign.gold.withValues(alpha: .35),
            ),
            boxShadow: [
              BoxShadow(
                color: MissionDesign.gold.withValues(alpha: .16),
                blurRadius: 32,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppDesign.red,
              border: Border.all(color: MissionDesign.gold, width: 5),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF3D889), width: 6),
              ),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: CustomPaint(painter: _SealPainter()),
              ),
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: MissionDesign.gold,
            borderRadius: BorderRadius.circular(AppDesign.radius),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              AppLocalizations.of(context).honoursFeat,
              style: context.text.labelSmall?.copyWith(
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Statistic extends StatelessWidget {
  const _Statistic({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
  final String value, label;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      CircleAvatar(
        radius: 16,
        backgroundColor: color.withValues(alpha: .1),
        child: Icon(icon, color: color, size: 18),
      ),
      MissionDesign.smallGap,
      Text(
        value,
        textAlign: TextAlign.center,
        style: MissionDesign.heading(context).copyWith(color: color),
      ),
      Text(label, textAlign: TextAlign.center, style: context.text.labelSmall),
    ],
  );
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard();
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: MissionDesign.contentPadding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDesign.radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, MissionDesign.paleGold],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDesign.radius),
                  boxShadow: [
                    BoxShadow(
                      color: MissionDesign.gold.withValues(alpha: .12),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_stories,
                  color: MissionDesign.gold,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.honoursBadgeNew,
                      style: context.text.labelSmall?.copyWith(
                        color: MissionDesign.gold,
                      ),
                    ),
                    MissionDesign.smallGap,
                    Text(
                      l.honoursBadgeTitle,
                      style: MissionDesign.heading(
                        context,
                        size: MissionDesign.sectionSize,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.honoursBadgeDescription,
                      style: context.text.bodySmall?.copyWith(
                        color: AppDesign.muted,
                        height: 1.5,
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
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: MissionDesign.paleGreen,
                  borderRadius: BorderRadius.circular(AppDesign.radius),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    l.honoursBadgePreview,
                    style: context.text.labelSmall?.copyWith(
                      color: MissionDesign.green,
                    ),
                  ),
                ),
              ),
              Text(
                l.honoursBadgeLevel,
                style: context.text.labelSmall?.copyWith(
                  color: MissionDesign.gold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Milestone extends StatelessWidget {
  const _Milestone({
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
    required this.color,
  });
  final IconData icon;
  final String title, description, status;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Surface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 22),
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

class _SealPainter extends CustomPainter {
  const _SealPainter();
  static const _rays = 16;
  static const _vertices = 16;
  static const _gold = Color(0xFFF3D889);
  static const _outerRatio = .46;
  static const _innerRatio = .12;
  static const _ringRatio = .48;
  static const _rayStartRatio = .33;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height);
    final line = Paint()
      ..color = _gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * _ringRatio, line);
    for (var i = 0; i < _rays; i++) {
      final angle = i * math.pi * 2 / _rays;
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + direction * (radius * _rayStartRatio),
        center + direction * (radius * _ringRatio),
        line,
      );
    }
    final star = Path();
    for (var i = 0; i < _vertices; i++) {
      final angle = i * math.pi * 2 / _vertices - math.pi / 2;
      final length = radius * (i.isEven ? _outerRatio : _innerRatio);
      final point = center + Offset(math.cos(angle), math.sin(angle)) * length;
      if (i == 0) {
        star.moveTo(point.dx, point.dy);
      } else {
        star.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(star..close(), Paint()..color = _gold);
  }

  @override
  bool shouldRepaint(covariant _SealPainter oldDelegate) => false;
}
