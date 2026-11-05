import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/features/auth/ui/auth_form_view_model.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

const _topGap = 48.0;
const _textGap = 8.0;

/// Logged-out library prompt: one filled sign-in, one secondary sign-up.
class ProfileGuestPrompt extends ConsumerStatefulWidget {
  const ProfileGuestPrompt({super.key});

  @override
  ConsumerState<ProfileGuestPrompt> createState() => _ProfileGuestPromptState();
}

class _ProfileGuestPromptState extends ConsumerState<ProfileGuestPrompt> {
  @override
  void initState() {
    super.initState();
    // The form notifier is autoDispose: hold it so the mode chosen here is
    // still set when the login screen first watches it.
    ref.listenManual(authFormViewModelProvider, (_, _) {});
  }

  void _open(AuthMode mode) {
    ref.read(authFormViewModelProvider.notifier).setMode(mode);
    context.push(AppRoutes.loginFor(AppRoutes.profile));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: _topGap),
        Text(
          l.profileGuestTitle,
          textAlign: TextAlign.center,
          style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: _textGap),
        Text(
          l.profileGuestMessage,
          textAlign: TextAlign.center,
          style: context.text.bodyMedium?.copyWith(color: AppDesign.muted),
        ),
        const SizedBox(height: AppDesign.pagePadding * 1.5),
        FilledButton(
          onPressed: () => _open(AuthMode.signIn),
          child: Text(l.profileSignInNow),
        ),
        const SizedBox(height: AppDesign.gap / 2),
        OutlinedButton(
          onPressed: () => _open(AuthMode.signUp),
          child: Text(l.profileSignUp),
        ),
      ],
    );
  }
}
