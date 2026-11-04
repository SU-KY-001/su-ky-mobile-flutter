import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

import 'auth_fields.dart';
import 'auth_form_view_model.dart';
import 'auth_mode_footer.dart';

const _spinnerSize = 20.0;
const _titleGap = 24.0;

/// Spotify-style login: plain page, stacked labelled fields, one filled
/// submit, mode switch as a text link at the bottom.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key, this.returnTo});

  /// Already validated by `AppRoutes.safeReturnTo`.
  final String? returnTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final form = ref.watch(authFormViewModelProvider);
    final signUp = form.mode == AuthMode.signUp;
    final vm = ref.read(authFormViewModelProvider.notifier);
    return AppPage(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.popOrGo(AppRoutes.home),
          tooltip: l.close,
          icon: const Icon(Icons.close),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDesign.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              signUp ? l.authSignUpHeading : l.loginHeading,
              style: context.text.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: _titleGap),
            const AuthFields(),
            const SizedBox(height: _titleGap),
            FilledButton(
              // Success replaces the stack with the destination: the session
              // change refreshes the router, and a pushed login page cannot be
              // popped after that refresh, so pop/pushReplacement are not safe.
              // The router is captured before the await: this widget may be
              // disposed while the request is in flight.
              onPressed: form.submitting
                  ? null
                  : () async {
                      final router = GoRouter.of(context);
                      if (!await vm.submit()) return;
                      router.go(returnTo ?? AppRoutes.home);
                    },
              child: form.submitting
                  ? const SizedBox.square(
                      dimension: _spinnerSize,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(signUp ? l.authSignUpAction : l.loginAction),
            ),
            const SizedBox(height: _titleGap),
            const AuthModeFooter(),
          ],
        ),
      ),
    );
  }
}
