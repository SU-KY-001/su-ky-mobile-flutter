import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

import 'login_view_model.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({
    super.key,
    required this.onClose,
    required this.onContinue,
  });
  final VoidCallback onClose, onContinue;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final form = ref.watch(loginViewModelProvider).requireValue;
    final vm = ref.read(loginViewModelProvider.notifier);
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
                  onPressed: onClose,
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
              l.loginHeading,
              textAlign: TextAlign.center,
              style: context.text.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -.7,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l.loginSubtitle,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(
                color: AppDesign.muted,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 32),
            Text(l.email, style: context.text.bodySmall),
            const SizedBox(height: 6),
            TextField(
              onChanged: vm.email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: InputDecoration(
                hintText: l.emailHint,
                prefixIcon: const Icon(Icons.mail_outline, size: 19),
                errorText: form.invalid ? l.invalidCredentials : null,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(l.password, style: context.text.bodySmall),
                const Spacer(),
                TextButton(
                  onPressed: notice,
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
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () {
                if (vm.submit()) onContinue();
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(l.loginAction),
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
                  color: Color(0xFF4285F4),
                ),
              ),
              label: Text(
                l.googleAction,
                style: const TextStyle(color: AppDesign.ink),
              ),
            ),
            const SizedBox(height: 74),
            const Divider(),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  l.noAccount,
                  style: context.text.bodySmall?.copyWith(
                    color: AppDesign.muted,
                  ),
                ),
                TextButton(
                  onPressed: notice,
                  child: Text(l.register, style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
