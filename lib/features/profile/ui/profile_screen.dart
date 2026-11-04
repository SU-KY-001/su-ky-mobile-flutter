import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/features/auth/ui/session_controller.dart';
import 'package:su_ky_mobile/features/profile/ui/profile_guest_card.dart';
import 'package:su_ky_mobile/features/profile/ui/profile_history_section.dart';
import 'package:su_ky_mobile/features/profile/ui/profile_user_card.dart';
import 'package:su_ky_mobile/features/profile/ui/profile_xp_card.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(sessionControllerProvider).user;
    return AppPage(
      child: ListView(
        padding: const EdgeInsets.all(AppDesign.pagePadding),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.profileTitle,
                  style: context.text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => context.push(AppRoutes.schedule),
                tooltip: l.profileScheduleTooltip,
                icon: const Icon(Icons.notifications_none),
              ),
            ],
          ),
          const SizedBox(height: AppDesign.pagePadding),
          if (user == null)
            const ProfileGuestCard()
          else ...[
            ProfileUserCard(
              user: user,
              onSignOut: () =>
                  ref.read(sessionControllerProvider.notifier).signOut(),
            ),
            const SizedBox(height: AppDesign.gap),
            const ProfileXpCard(),
            const SizedBox(height: AppDesign.pagePadding),
            const ProfileHistorySection(),
          ],
        ],
      ),
    );
  }
}
