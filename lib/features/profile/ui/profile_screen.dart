import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/features/auth/ui/session_controller.dart';
import 'package:su_ky_mobile/features/profile/ui/profile_group.dart';
import 'package:su_ky_mobile/features/profile/ui/profile_guest_prompt.dart';
import 'package:su_ky_mobile/features/profile/ui/profile_history_section.dart';
import 'package:su_ky_mobile/features/profile/ui/profile_missions_row.dart';
import 'package:su_ky_mobile/features/profile/ui/profile_schedule_row.dart';
import 'package:su_ky_mobile/features/profile/ui/profile_sign_out_row.dart';
import 'package:su_ky_mobile/features/profile/ui/profile_stats.dart';
import 'package:su_ky_mobile/features/profile/ui/profile_user_header.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

const _headerGap = 16.0;
const _pagePadding = EdgeInsets.fromLTRB(
  AppDesign.pagePadding,
  8,
  AppDesign.pagePadding,
  32,
);

/// YouTube "You" page hierarchy: identity header, summary block, then labelled
/// groups (activity, recent listening, account) instead of one flat list.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(sessionControllerProvider).user;
    return AppPage(
      appBar: AppBar(
        title: Text(l.profileTitle),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.schedule),
            tooltip: l.profileScheduleTooltip,
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      child: user == null
          ? const SingleChildScrollView(
              padding: _pagePadding,
              child: ProfileGuestPrompt(),
            )
          : ListView(
              padding: _pagePadding,
              children: [
                ProfileUserHeader(user: user),
                const SizedBox(height: _headerGap),
                const ProfileStats(),
                ProfileSectionLabel(l.profileSectionActivity),
                const ProfileGroup(
                  children: [ProfileMissionsRow(), ProfileScheduleRow()],
                ),
                ProfileSectionLabel(l.profileRecentTitle),
                const ProfileHistorySection(),
                ProfileSectionLabel(l.profileSectionAccount),
                const ProfileGroup(children: [ProfileSignOutRow()]),
              ],
            ),
    );
  }
}
