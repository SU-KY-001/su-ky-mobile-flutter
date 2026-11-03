import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

import '../domain/quiz.dart';
import 'quiz_colors.dart';
import 'quiz_info_tiles.dart';
import 'quiz_text.dart';

const _itemRadius = 16.0;

class QuizReviewItem extends StatelessWidget {
  const QuizReviewItem({super.key, required this.attempt, required this.index});
  final QuizAttempt attempt;
  final int index;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final definition = QuizDefinition.questions[index];
    final (question, options, explanation) = quizText(l, definition.id);
    final correct = attempt.answers[index] == definition.correctOption;
    final stateColor = correct ? QuizColors.green : AppDesign.red;
    return Material(
      color: AppDesign.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_itemRadius),
        side: const BorderSide(color: AppDesign.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: ValueKey(definition.id),
        initiallyExpanded: !correct,
        leading: Icon(
          correct ? Icons.check_circle : Icons.cancel,
          color: stateColor,
        ),
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, height: 1.5),
        ),
        subtitle: Text(
          '${l.quizCounter(index + 1, QuizDefinition.questions.length)} · ${correct ? l.quizCorrect : l.quizIncorrect}',
          style: TextStyle(fontSize: 11, color: stateColor),
        ),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          if (!correct) ...[
            QuizAnswerBox(
              label: l.quizYourAnswer,
              body: options[attempt.answers[index]],
              color: QuizColors.redTint,
            ),
            const SizedBox(height: 10),
          ],
          QuizAnswerBox(
            label: l.quizRightAnswer,
            body: options[definition.correctOption],
            color: QuizColors.greenTint,
          ),
          const SizedBox(height: 10),
          QuizAnswerBox(
            label: l.quizExplanation,
            body: explanation,
            color: QuizColors.soft,
          ),
        ],
      ),
    );
  }
}
