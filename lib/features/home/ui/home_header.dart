import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/features/home/ui/home_avatar_button.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

/// Spotify/YouTube-style top row: brand title left, search, missions and the
/// account avatar right.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: AppDesign.pagePadding),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l.appName,
              style: context.text.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: () => context.push(AppRoutes.search),
            tooltip: l.search,
            icon: const Icon(Symbols.search),
          ),
          IconButton(
            onPressed: () => context.push(AppRoutes.weeklyMissions),
            tooltip: l.weeklyMissions,
            icon: const Icon(Symbols.emoji_events),
          ),
          const HomeAvatarButton(),
        ],
      ),
    );
  }
}
