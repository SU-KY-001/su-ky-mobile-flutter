import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

import '../domain/quiz.dart';
import 'quiz_colors.dart';
import 'quiz_info_tiles.dart';

const _itemRadius = 16.0;
const _borderWidth = 1.0;
const _childrenPadding = 16.0;
const _boxGap = 10.0;
const _subtitleSize = 11.0;
const _titleHeight = 1.5;

class QuizReviewItem extends StatelessWidget {
  const QuizReviewItem({
    super.key,
    required this.entry,
    required this.position,
    required this.total,
  });

  final QuizReviewEntry entry;

  /// One-based position inside the full review list.
  final int position;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final correct = entry.answer.isCorrect;
    final stateColor = correct ? QuizColors.green : AppDesign.red;
    final selected = entry.selectedOption;
    final right = entry.correctOption;
    final explanation = entry.answer.explanation;
    return Material(
      color: AppDesign.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_itemRadius),
        side: const BorderSide(color: AppDesign.line, width: _borderWidth),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: ValueKey(entry.question.id),
        initiallyExpanded: !correct,
        leading: Icon(
          correct ? Icons.check_circle : Icons.cancel,
          color: stateColor,
        ),
        title: Text(
          entry.question.text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            height: _titleHeight,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.quizCounter(position, total),
              style: const TextStyle(fontSize: _subtitleSize),
            ),
            Text(
              correct ? l.quizCorrect : l.quizIncorrect,
              style: TextStyle(fontSize: _subtitleSize, color: stateColor),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.all(_childrenPadding),
        children: [
          if (selected != null) ...[
            QuizAnswerBox(
              label: l.quizYourAnswer,
              body: l.quizOptionLine(selected.label, selected.text),
              color: correct ? QuizColors.greenTint : QuizColors.redTint,
            ),
            const SizedBox(height: _boxGap),
          ],
          if (!correct && right != null) ...[
            QuizAnswerBox(
              label: l.quizRightAnswer,
              body: l.quizOptionLine(right.label, right.text),
              color: QuizColors.greenTint,
            ),
            const SizedBox(height: _boxGap),
          ],
          if (explanation != null)
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
