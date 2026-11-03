import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

import 'quiz_colors.dart';
import 'quiz_primitives.dart';

/// Result banner and explanation shown after a question is checked.
class QuizFeedbackCard extends StatelessWidget {
  const QuizFeedbackCard({
    super.key,
    required this.isCorrect,
    required this.explanation,
  });
  final bool isCorrect;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return QuizCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? QuizColors.green : AppDesign.red,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: QuizHeading(
                  isCorrect ? l.quizCorrect : l.quizIncorrect,
                  size: 20,
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          QuizEyebrow(l.quizExplanation),
          const SizedBox(height: 12),
          Text(explanation, style: const TextStyle(height: 1.7)),
          const SizedBox(height: 16),
          Text(
            l.quizSource,
            style: const TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: AppDesign.muted,
            ),
          ),
        ],
      ),
    );
  }
}
