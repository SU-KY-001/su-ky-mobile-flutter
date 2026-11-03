import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: context.accent,
          radius: 17,
          child: const Icon(
            Icons.auto_stories_outlined,
            color: AppDesign.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.appName,
                style: context.text.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                l.audioHistory,
                style: context.text.labelSmall?.copyWith(
                  letterSpacing: 1.4,
                  color: AppDesign.muted,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => context.push(AppRoutes.login),
          icon: CircleAvatar(
            radius: 18,
            backgroundColor: AppDesign.tint,
            child: Text(l.initials, style: context.text.labelMedium),
          ),
        ),
      ],
    );
  }
}
