import 'package:flutter/material.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_missions_colors.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

/// White rounded card with the soft shadow used across the missions screen.
class MissionsPanel extends StatelessWidget {
  const MissionsPanel({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final Color color;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(17),
      boxShadow: [
        BoxShadow(
          color: WeeklyMissionsColors.shadow.withValues(alpha: 0.035),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: child,
  );
}

class MissionsProgressBar extends StatelessWidget {
  const MissionsProgressBar({
    super.key,
    required this.progress,
    this.height = 7,
  });

  final double progress;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: LinearProgressIndicator(
      value: progress.clamp(0.0, 1.0),
      minHeight: height,
      backgroundColor: WeeklyMissionsColors.progressTrack,
      valueColor: const AlwaysStoppedAnimation<Color>(AppDesign.red),
    ),
  );
}
