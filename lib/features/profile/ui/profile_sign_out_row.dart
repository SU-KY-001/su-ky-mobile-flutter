import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:su_ky_mobile/features/auth/ui/session_controller.dart';
import 'package:su_ky_mobile/features/profile/ui/profile_nav_row.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';

/// Destructive row in its own group; signing out always asks first.
class ProfileSignOutRow extends ConsumerWidget {
  const ProfileSignOutRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return ProfileNavRow(
      icon: Symbols.logout,
      title: l.profileSignOut,
      danger: true,
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => const _ConfirmDialog(),
        );
        if (confirmed == true) {
          await ref.read(sessionControllerProvider.notifier).signOut();
        }
      },
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.profileSignOutConfirmTitle),
      content: Text(l.profileSignOutConfirmMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l.profileSignOutCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l.profileSignOut),
        ),
      ],
    );
  }
}
