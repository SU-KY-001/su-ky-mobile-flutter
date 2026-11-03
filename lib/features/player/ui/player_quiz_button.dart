import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';

const _topGap = 24.0;
const _iconSize = 18.0;

/// Opens the episode quiz; the route guard sends guests to login first.
class PlayerQuizButton extends StatelessWidget {
  const PlayerQuizButton({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: _topGap),
    child: SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => context.push(AppRoutes.quizFor(slug)),
        icon: const Icon(Icons.emoji_events_outlined, size: _iconSize),
        label: Text(AppLocalizations.of(context).playerStartQuiz),
      ),
    ),
  );
}
