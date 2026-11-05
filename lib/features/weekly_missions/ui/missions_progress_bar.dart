import 'package:flutter/material.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

const _barHeight = 10.0;

/// Thick rounded bar (Duolingo quest progress).
class MissionsProgressBar extends StatelessWidget {
  const MissionsProgressBar({super.key, required this.progress, this.color});

  final double progress;
  final Color? color;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(_barHeight),
    child: LinearProgressIndicator(
      value: progress.clamp(0.0, 1.0),
      minHeight: _barHeight,
      backgroundColor: AppDesign.line,
      valueColor: AlwaysStoppedAnimation<Color>(color ?? AppDesign.red),
    ),
  );
}
