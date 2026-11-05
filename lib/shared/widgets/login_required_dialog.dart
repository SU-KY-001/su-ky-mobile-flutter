import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';

/// Signed-out gate shown when a guest taps Play. Pops `true` when the user
/// chooses to sign in; the caller owns navigation so Back returns to the
/// screen where Play was tapped.
class LoginRequiredDialog extends StatelessWidget {
  const LoginRequiredDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.loginRequiredTitle),
      content: Text(l.loginRequiredMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l.loginRequiredLater),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l.loginRequiredAction),
        ),
      ],
    );
  }
}
