import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

import '../domain/quiz.dart';
import 'quiz_colors.dart';
import 'quiz_primitives.dart';
import 'quiz_review_item.dart';
import 'quiz_view_model.dart';

const _progressHeight = 6.0;

class QuizReviewView extends StatelessWidget {
  const QuizReviewView({super.key, required this.session, required this.vm});
  final QuizSession session;
  final QuizViewModel vm;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = session;
    final attempt = s.attempt!;
    final total = QuizDefinition.questions.length;
    final indices = [
      for (var i = 0; i < total; i++)
        if (s.filter == QuizFilter.all ||
            (attempt.answers[i] == QuizDefinition.questions[i].correctOption) ==
                (s.filter == QuizFilter.correct))
          i,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuizCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuizHeading(l.bachDang, size: 22),
              const SizedBox(height: 10),
              Text(l.quizScore(attempt.correctCount, total)),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: attempt.percent / 100,
                color: QuizColors.green,
                backgroundColor: AppDesign.red,
                minHeight: _progressHeight,
              ),
              const SizedBox(height: 12),
              Text(l.quizAccuracy(attempt.percent)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FilterChip(
              label: l.quizFilterAll(total),
              active: s.filter == QuizFilter.all,
              onSelected: () => vm.filter(QuizFilter.all),
            ),
            _FilterChip(
              label: l.quizFilterWrong(total - attempt.correctCount),
              active: s.filter == QuizFilter.incorrect,
              onSelected: () => vm.filter(QuizFilter.incorrect),
            ),
            _FilterChip(
              label: l.quizFilterRight(attempt.correctCount),
              active: s.filter == QuizFilter.correct,
              onSelected: () => vm.filter(QuizFilter.correct),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (indices.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l.quizNoMatches),
          ),
        for (final i in indices) ...[
          QuizReviewItem(attempt: attempt, index: i),
          const SizedBox(height: 14),
        ],
        const SizedBox(height: 12),
        QuizPrimaryButton(
          l.quizBackResults,
          vm.summary,
          icon: Icons.arrow_back,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onSelected,
  });
  final String label;
  final bool active;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(
      label,
      style: TextStyle(
        fontFamily: 'Inter',
        color: active ? AppDesign.white : AppDesign.ink,
      ),
    ),
    selected: active,
    onSelected: (_) => onSelected(),
  );
}
