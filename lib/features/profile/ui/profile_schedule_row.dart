import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/features/profile/ui/profile_nav_row.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';

class ProfileScheduleRow extends StatelessWidget {
  const ProfileScheduleRow({super.key});

  @override
  Widget build(BuildContext context) => ProfileNavRow(
    icon: Icons.calendar_month_outlined,
    title: AppLocalizations.of(context).scheduleTitle,
    onTap: () => context.push(AppRoutes.schedule),
  );
}
