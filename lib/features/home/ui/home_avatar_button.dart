import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/features/auth/ui/session_controller.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/user_avatar.dart';

const _avatarRadius = 16.0;

/// YouTube-style account avatar in the top-right corner. Guests see the
/// outline icon; signed-in users see their photo or initial. Opens the profile.
class HomeAvatarButton extends ConsumerWidget {
  const HomeAvatarButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionControllerProvider).user;
    final l = AppLocalizations.of(context);
    return IconButton(
      onPressed: () => context.push(AppRoutes.profile),
      tooltip: l.profileTitle,
      icon: user == null
          ? const _GuestAvatar()
          : UserAvatar(user: user, radius: _avatarRadius),
    );
  }
}

class _GuestAvatar extends StatelessWidget {
  const _GuestAvatar();

  @override
  Widget build(BuildContext context) => const CircleAvatar(
    radius: _avatarRadius,
    backgroundColor: AppDesign.tint,
    child: Icon(Symbols.person, size: 20, color: AppDesign.muted),
  );
}
