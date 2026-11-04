import 'package:flutter/material.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

const _actionExtent = 48.0;

/// Minimise row with the "playing from series" eyebrow.
class PlayerHeader extends StatelessWidget {
  const PlayerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: () => context.popOrGo(AppRoutes.home),
          tooltip: l.close,
          icon: const Icon(Icons.keyboard_arrow_down),
        ),
        Expanded(
          child: Text(
            l.playerFromSeries,
            textAlign: TextAlign.center,
            style: context.text.labelSmall?.copyWith(
              letterSpacing: .8,
              color: AppDesign.muted,
            ),
          ),
        ),
        const SizedBox(width: _actionExtent),
      ],
    );
  }
}
