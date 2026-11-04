import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

import '../domain/quiz.dart';
import 'quiz_colors.dart';

const _rowPadding = EdgeInsets.fromLTRB(
  AppDesign.pagePadding,
  0,
  AppDesign.pagePadding,
  AppDesign.pagePadding,
);
const _lineGap = 12.0;
const _labelSize = 12.0;
const _titleHeight = 1.4;

/// One review row: check/cross icon, question, expandable answer details.
class QuizReviewItem extends StatelessWidget {
  const QuizReviewItem({super.key, required this.entry});

  final QuizReviewEntry entry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final correct = entry.answer.isCorrect;
    final selected = entry.selectedOption;
    final right = entry.correctOption;
    final explanation = entry.answer.explanation;
    return ExpansionTile(
      key: ValueKey(entry.question.id),
      initiallyExpanded: !correct,
      shape: const Border(),
      collapsedShape: const Border(),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      expandedAlignment: Alignment.centerLeft,
      leading: Icon(
        correct ? Icons.check_circle : Icons.cancel,
        color: correct ? QuizColors.green : AppDesign.red,
      ),
      title: Text(
        entry.question.text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          height: _titleHeight,
        ),
      ),
      childrenPadding: _rowPadding,
      children: [
        if (selected != null)
          _Line(
            label: l.quizYourAnswer,
            body: l.quizOptionLine(selected.label, selected.text),
          ),
        if (!correct && right != null)
          _Line(
            label: l.quizRightAnswer,
            body: l.quizOptionLine(right.label, right.text),
          ),
        if (explanation != null)
          _Line(label: l.quizExplanation, body: explanation),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.body});

  final String label;
  final String body;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: _lineGap),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: _labelSize, color: AppDesign.muted),
        ),
        Text(body),
      ],
    ),
  );
}
