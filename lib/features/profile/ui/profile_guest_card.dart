import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

const _iconSize = 40.0;

class ProfileGuestCard extends StatelessWidget {
  const ProfileGuestCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Surface(
      padding: const EdgeInsets.all(AppDesign.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.account_circle_outlined,
            size: _iconSize,
            color: context.accent,
          ),
          const SizedBox(height: AppDesign.gap),
          Text(
            l.profileGuestTitle,
            textAlign: TextAlign.center,
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.profileGuestMessage,
            textAlign: TextAlign.center,
            style: context.text.bodyMedium?.copyWith(color: AppDesign.muted),
          ),
          const SizedBox(height: AppDesign.pagePadding),
          FilledButton(
            onPressed: () => context.push(AppRoutes.login),
            child: Text(l.profileSignInNow),
          ),
        ],
      ),
    );
  }
}
