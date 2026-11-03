import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

import 'auth_form_view_model.dart';

/// Name (sign-up only), email and password inputs plus the form error line.
class AuthFields extends ConsumerWidget {
  const AuthFields({required this.onForgotPassword, super.key});

  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final form = ref.watch(authFormViewModelProvider);
    final vm = ref.read(authFormViewModelProvider.notifier);
    final signUp = form.mode == AuthMode.signUp;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (signUp) ...[
          Text(l.name, style: context.text.bodySmall),
          const SizedBox(height: 6),
          TextField(
            onChanged: vm.name,
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.name],
            decoration: InputDecoration(
              hintText: l.nameHint,
              prefixIcon: const Icon(Icons.person_outline, size: 19),
            ),
          ),
          const SizedBox(height: 10),
        ],
        Text(l.email, style: context.text.bodySmall),
        const SizedBox(height: 6),
        TextField(
          onChanged: vm.email,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: InputDecoration(
            hintText: l.emailHint,
            prefixIcon: const Icon(Icons.mail_outline, size: 19),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(l.password, style: context.text.bodySmall),
            const Spacer(),
            if (!signUp)
              TextButton(
                onPressed: onForgotPassword,
                child: Text(
                  l.forgotPassword,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
        TextField(
          onChanged: vm.password,
          obscureText: form.obscured,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline, size: 19),
            suffixIcon: IconButton(
              onPressed: vm.toggleVisibility,
              tooltip: l.password,
              icon: Icon(
                form.obscured
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 19,
              ),
            ),
          ),
        ),
        if (form.error case final error?) ...[
          const SizedBox(height: 10),
          Text(
            _message(l, error),
            style: context.text.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  String _message(AppLocalizations l, AuthFormError error) => switch (error) {
    AuthFormError.invalidInput => l.invalidCredentials,
    AuthFormError.wrongCredentials => l.authWrongCredentials,
    AuthFormError.emailTaken => l.authEmailTaken,
    AuthFormError.network => l.authNetworkError,
    AuthFormError.unknown => l.authUnknownError,
  };
}
