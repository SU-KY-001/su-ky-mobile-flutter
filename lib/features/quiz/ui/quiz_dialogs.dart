import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';

/// Asks whether to abandon the running quiz; true means leave.
Future<bool> confirmQuizExit(BuildContext context) async {
  final l = AppLocalizations.of(context);
  final leave = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l.quizExitTitle),
      content: Text(l.quizExitBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.quizContinue),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l.quizExit),
        ),
      ],
    ),
  );
  return leave == true;
}

Future<void> showQuizHelp(BuildContext context) {
  final l = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l.quizHelp),
      content: Text(l.quizHelpBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.close),
        ),
      ],
    ),
  );
}
