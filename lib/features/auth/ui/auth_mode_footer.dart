import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

import 'auth_form_view_model.dart';

/// Switches the single auth screen between sign-in and sign-up.
class AuthModeFooter extends ConsumerWidget {
  const AuthModeFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final signUp = ref.watch(
      authFormViewModelProvider.select((s) => s.mode == AuthMode.signUp),
    );
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          signUp ? l.haveAccount : l.noAccount,
          style: context.text.bodySmall?.copyWith(color: AppDesign.muted),
        ),
        TextButton(
          onPressed: () => ref
              .read(authFormViewModelProvider.notifier)
              .setMode(signUp ? AuthMode.signIn : AuthMode.signUp),
          child: Text(
            signUp ? l.signIn : l.register,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
