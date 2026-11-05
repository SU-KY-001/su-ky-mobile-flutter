import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/features/profile/ui/profile_nav_row.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/missions/missions_providers.dart';

/// Activity-group row to weekly missions, with the XP total once loaded.
class ProfileMissionsRow extends ConsumerWidget {
  const ProfileMissionsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final xp = ref.watch(weeklyMissionsProvider).value?.totalXp;
    return ProfileNavRow(
      icon: Symbols.emoji_events,
      title: l.missionsHeaderTitle,
      value: xp == null ? null : l.profileXpTotal(xp),
      onTap: () => context.push(AppRoutes.weeklyMissions),
    );
  }
}
