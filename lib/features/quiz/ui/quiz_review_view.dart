import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

import '../domain/quiz.dart' as domain;
import '../domain/quiz_stage.dart';
import 'quiz_bottom_bar.dart';
import 'quiz_chip.dart';
import 'quiz_review_item.dart';
import 'quiz_session.dart';
import 'quiz_view_model.dart';

const _chipGap = 8.0;
const _chipsBottomGap = 8.0;
const _emptyGap = 24.0;

class QuizReviewView extends StatelessWidget {
  const QuizReviewView({
    super.key,
    required this.session,
    required this.viewModel,
  });

  final QuizSession session;
  final QuizViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final entries = session.reviewEntries;
    final visible = entries.where(_matchesFilter).toList(growable: false);
    final correct = session.correctCount;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: _chipsBottomGap),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDesign.pagePadding,
                  vertical: _chipsBottomGap,
                ),
                child: Wrap(
                  spacing: _chipGap,
                  runSpacing: _chipGap,
                  children: [
                    QuizChoiceChip(
                      label: l.quizFilterAll(entries.length),
                      selected: session.filter == QuizFilter.all,
                      onSelected: () => viewModel.filter(QuizFilter.all),
                    ),
                    QuizChoiceChip(
                      label: l.quizFilterWrong(session.total - correct),
                      selected: session.filter == QuizFilter.incorrect,
                      onSelected: () => viewModel.filter(QuizFilter.incorrect),
                    ),
                    QuizChoiceChip(
                      label: l.quizFilterRight(correct),
                      selected: session.filter == QuizFilter.correct,
                      onSelected: () => viewModel.filter(QuizFilter.correct),
                    ),
                  ],
                ),
              ),
              if (visible.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(_emptyGap),
                  child: Text(l.quizNoMatches),
                ),
              for (final entry in visible) ...[
                const Divider(height: 1),
                QuizReviewItem(entry: entry),
              ],
            ],
          ),
        ),
        QuizBottomBar(label: l.quizBackResults, onPressed: viewModel.summary),
      ],
    );
  }

  bool _matchesFilter(domain.QuizReviewEntry entry) {
    if (session.filter == QuizFilter.all) return true;
    final correct = entry.answer.isCorrect;
    return session.filter == QuizFilter.correct ? correct : !correct;
  }
}
