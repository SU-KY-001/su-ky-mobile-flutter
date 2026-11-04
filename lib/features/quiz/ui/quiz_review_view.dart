import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

import '../domain/quiz.dart' as domain;
import '../domain/quiz_stage.dart';
import 'quiz_chip.dart';
import 'quiz_colors.dart';
import 'quiz_primitives.dart';
import 'quiz_review_item.dart';
import 'quiz_session.dart';
import 'quiz_view_model.dart';

const _progressHeight = 6.0;
const _percentScale = 100;
const _sectionGap = 18.0;
const _itemGap = 14.0;
const _chipGap = 8.0;
const _scoreGap = 10.0;
const _emptyGap = 24.0;
const _cardHeadingSize = 22.0;
const _buttonGap = 12.0;

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
    final result = session.result;
    if (result == null) return const SizedBox.shrink();
    final entries = session.reviewEntries;
    final visible = entries.where(_matchesFilter).toList(growable: false);
    final correct = session.correctCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuizCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuizHeading(l.quizReviewTitle, size: _cardHeadingSize),
              const SizedBox(height: _scoreGap),
              Text(l.quizScore(correct, session.total)),
              const SizedBox(height: _sectionGap),
              LinearProgressIndicator(
                value: result.scorePercent / _percentScale,
                color: QuizColors.green,
                backgroundColor: AppDesign.red,
                minHeight: _progressHeight,
              ),
              const SizedBox(height: _scoreGap),
              Text(l.quizAccuracy(result.scorePercent)),
            ],
          ),
        ),
        const SizedBox(height: _sectionGap),
        Wrap(
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
        const SizedBox(height: _sectionGap),
        if (visible.isEmpty)
          Padding(
            padding: const EdgeInsets.all(_emptyGap),
            child: Text(l.quizNoMatches),
          ),
        for (final entry in visible) ...[
          QuizReviewItem(
            entry: entry,
            position: entries.indexOf(entry) + 1,
            total: session.total,
          ),
          const SizedBox(height: _itemGap),
        ],
        const SizedBox(height: _buttonGap),
        QuizPrimaryButton(
          l.quizBackResults,
          viewModel.summary,
          icon: Icons.arrow_back,
        ),
      ],
    );
  }

  bool _matchesFilter(domain.QuizReviewEntry entry) {
    if (session.filter == QuizFilter.all) return true;
    final correct = entry.answer.isCorrect;
    return session.filter == QuizFilter.correct ? correct : !correct;
  }
}
