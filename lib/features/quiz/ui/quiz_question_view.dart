import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/cover_art.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

import '../domain/quiz.dart';
import 'quiz_colors.dart';
import 'quiz_feedback_card.dart';
import 'quiz_option_tile.dart';
import 'quiz_primitives.dart';
import 'quiz_text.dart';
import 'quiz_view_model.dart';

const _progressHeight = 6.0;
const _progressRadius = 5.0;
const _feedbackCoverHeight = 135.0;

class QuizQuestionView extends StatelessWidget {
  const QuizQuestionView({super.key, required this.session, required this.vm});
  final QuizSession session;
  final QuizViewModel vm;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = session;
    final (question, options, explanation) = quizText(l, s.question.id);
    final total = QuizDefinition.questions.length;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            key: ValueKey(s.questionIndex),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: QuizEyebrow(l.quizProgress)),
                    Text(
                      l.quizCounter(s.questionIndex + 1, total),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (s.questionIndex + 1) / total,
                  minHeight: _progressHeight,
                  borderRadius: BorderRadius.circular(_progressRadius),
                  backgroundColor: AppDesign.line,
                ),
                const SizedBox(height: 22),
                if (s.checked) ...[
                  const CoverArt(height: _feedbackCoverHeight),
                  const SizedBox(height: 20),
                ],
                QuizCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Chip(
                        label: Text(
                          l.quizCategory,
                          style: const TextStyle(fontFamily: 'Inter'),
                        ),
                        backgroundColor: QuizColors.goldTint,
                        labelStyle: const TextStyle(
                          color: QuizColors.gold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      QuizHeading(question, size: 21),
                      if (!s.checked) ...[
                        const SizedBox(height: 16),
                        Text(
                          l.quizInstruction,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: AppDesign.muted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < options.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: QuizOptionTile(
                      session: s,
                      text: options[i],
                      index: i,
                      onSelect: vm.select,
                    ),
                  ),
                if (s.checked)
                  QuizFeedbackCard(
                    isCorrect: s.isCorrect,
                    explanation: explanation,
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: SizedBox(
            width: double.infinity,
            child: QuizPrimaryButton(
              s.checked ? (s.isLast ? l.quizFinish : l.quizNext) : l.quizCheck,
              s.saving || (!s.checked && s.selected == null)
                  ? null
                  : (s.checked ? vm.next : vm.check),
            ),
          ),
        ),
      ],
    );
  }
}
