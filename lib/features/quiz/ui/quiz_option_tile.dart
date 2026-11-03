import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

import '../domain/quiz.dart';
import 'quiz_colors.dart';

const _optionRadius = 16.0;
const _firstOptionLetterCode = 65; // 'A'
const _selectedBorderWidth = 2.0;

class QuizOptionTile extends StatelessWidget {
  const QuizOptionTile({
    super.key,
    required this.session,
    required this.text,
    required this.index,
    required this.onSelect,
  });
  final QuizSession session;
  final String text;
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = session;
    final selected = s.selected == index;
    final correct = s.checked && s.question.correctOption == index;
    final wrong = s.checked && selected && !correct;
    final color = correct
        ? QuizColors.green
        : wrong || selected
        ? AppDesign.red
        : AppDesign.line;
    return Material(
      color: correct
          ? QuizColors.greenTint
          : wrong
          ? QuizColors.redTint
          : selected
          ? AppDesign.tint
          : AppDesign.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_optionRadius),
        side: BorderSide(
          color: color,
          width: selected || correct ? _selectedBorderWidth : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: s.checked ? null : () => onSelect(index),
        child: Semantics(
          selected: selected,
          label: correct ? l.quizRightAnswer : null,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  correct
                      ? Icons.check_circle
                      : wrong
                      ? Icons.cancel
                      : selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: color == AppDesign.line ? AppDesign.muted : color,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${String.fromCharCode(_firstOptionLetterCode + index)}.  $text',
                        style: TextStyle(
                          height: 1.6,
                          fontWeight: selected || correct
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      if (correct) ...[
                        const SizedBox(height: 8),
                        Text(
                          l.quizRightAnswer,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: QuizColors.green,
                          ),
                        ),
                      ],
                      if (wrong) ...[
                        const SizedBox(height: 8),
                        Text(
                          l.quizYourAnswer,
                          style: const TextStyle(color: AppDesign.red),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
