import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/features/auth/ui/auth_colors.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

import 'auth_fields.dart';
import 'auth_form_view_model.dart';
import 'auth_mode_footer.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final form = ref.watch(authFormViewModelProvider);
    final signUp = form.mode == AuthMode.signUp;
    final vm = ref.read(authFormViewModelProvider.notifier);
    void notice() =>
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.demoNotice)));
    return AppPage(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDesign.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton.outlined(
                  onPressed: () => context.popOrGo(AppRoutes.home),
                  tooltip: l.close,
                  icon: const Icon(Icons.close),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppDesign.line),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    '•  ${l.brandAudio}',
                    style: context.text.labelSmall?.copyWith(
                      color: AppDesign.muted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 86),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppDesign.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppDesign.line, width: 5),
                ),
                child: Icon(
                  Icons.explore_outlined,
                  color: context.accent,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              signUp ? l.authSignUpHeading : l.loginHeading,
              textAlign: TextAlign.center,
              style: context.text.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -.7,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              signUp ? l.authSignUpSubtitle : l.loginSubtitle,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(
                color: AppDesign.muted,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 32),
            AuthFields(onForgotPassword: notice),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: form.submitting
                  ? null
                  : () async {
                      final ok = await vm.submit();
                      if (ok && context.mounted) {
                        context.popOrGo(AppRoutes.home);
                      }
                    },
              icon: form.submitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow_rounded),
              label: Text(signUp ? l.authSignUpAction : l.loginAction),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    l.orContinue,
                    style: context.text.labelSmall?.copyWith(
                      color: AppDesign.muted,
                    ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: notice,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 48),
                backgroundColor: AppDesign.white,
                side: const BorderSide(color: AppDesign.line),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              icon: const Text(
                'G',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AuthColors.googleBlue,
                ),
              ),
              label: Text(
                l.googleAction,
                style: const TextStyle(color: AppDesign.ink),
              ),
            ),
            const SizedBox(height: 74),
            const Divider(),
            const AuthModeFooter(),
          ],
        ),
      ),
    );
  }
}
