import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/mission_widgets.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_missions_colors.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

class HonoursMedallion extends StatelessWidget {
  const HonoursMedallion({super.key});

  @override
  Widget build(BuildContext context) {
    final feat = AppLocalizations.of(context).honoursFeat;
    return Semantics(
      label: feat,
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
                  border: Border.all(
                    color: WeeklyMissionsColors.sealGold,
                    width: 6,
                  ),
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
                feat,
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
}

class _SealPainter extends CustomPainter {
  const _SealPainter();
  static const _rays = 16;
  static const _vertices = 16;
  static const _outerRatio = .46;
  static const _innerRatio = .12;
  static const _ringRatio = .48;
  static const _rayStartRatio = .33;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height);
    final line = Paint()
      ..color = WeeklyMissionsColors.sealGold
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
    canvas.drawPath(
      star..close(),
      Paint()..color = WeeklyMissionsColors.sealGold,
    );
  }

  @override
  bool shouldRepaint(covariant _SealPainter oldDelegate) => false;
}
