import 'package:flutter/material.dart';

import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_missions_colors.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

abstract final class MissionDesign {
  static const gold = WeeklyMissionsColors.gold;
  static const green = WeeklyMissionsColors.green;
  static const paleGreen = WeeklyMissionsColors.paleGreen;
  static const headingSize = 25.0;
  static const sectionSize = 20.0;

  static TextStyle heading(BuildContext context, {double size = headingSize}) =>
      context.text.headlineSmall!.copyWith(
        fontFamily: 'Inter',
        fontSize: size,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: AppDesign.ink,
      );
}
