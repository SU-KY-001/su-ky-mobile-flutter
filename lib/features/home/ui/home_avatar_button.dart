import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/core/auth/session_user.dart';
import 'package:su_ky_mobile/features/auth/ui/session_controller.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

const _avatarRadius = 16.0;

/// YouTube-style account avatar in the top-right corner. Guests see the
/// outline icon; signed-in users see their initial. Opens the profile page.
class HomeAvatarButton extends ConsumerWidget {
  const HomeAvatarButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionControllerProvider).user;
    final l = AppLocalizations.of(context);
    return IconButton(
      onPressed: () => context.push(AppRoutes.profile),
      tooltip: l.profileTitle,
      icon: CircleAvatar(
        radius: _avatarRadius,
        backgroundColor: AppDesign.tint,
        child: user == null
            ? const Icon(Icons.person_outline, size: 20, color: AppDesign.muted)
            : _Initial(user: user),
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial({required this.user});

  final SessionUser user;

  @override
  Widget build(BuildContext context) {
    final name = user.name.trim();
    return Text(
      name.isEmpty ? '?' : name.characters.first.toUpperCase(),
      style: context.text.labelLarge?.copyWith(
        color: context.accent,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
