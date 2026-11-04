import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

import 'quiz_colors.dart';
import 'quiz_episode_card.dart';
import 'quiz_navigation.dart';
import 'quiz_primitives.dart';
import 'quiz_session.dart';
import 'quiz_view_model.dart';

const _trophySize = 100.0;
const _sectionGap = 20.0;
const _scoreGap = 12.0;
const _statusGap = 24.0;
const _buttonGap = 12.0;
const _scoreSize = 30.0;
const _statusSize = 23.0;
const _accuracySize = 17.0;

class QuizSummaryView extends StatelessWidget {
  const QuizSummaryView({
    super.key,
    required this.session,
    required this.viewModel,
    required this.slug,
  });

  final QuizSession session;
  final QuizViewModel viewModel;
  final String slug;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final result = session.result;
    if (result == null) return const SizedBox.shrink();
    final statusColor = result.isPassed ? QuizColors.green : AppDesign.red;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: _sectionGap),
        Icon(
          result.isPassed
              ? Icons.workspace_premium_outlined
              : Icons.school_outlined,
          size: _trophySize,
          color: statusColor,
        ),
        const SizedBox(height: _sectionGap),
        Text(
          l.quizScore(session.correctCount, session.total),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: _scoreSize,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: _scoreGap),
        Text(
          l.quizAccuracy(result.scorePercent),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: QuizColors.gold,
            fontSize: _accuracySize,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: _statusGap),
        Text(
          result.isPassed ? l.quizPassed : l.quizFailed,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: _statusSize,
            fontWeight: FontWeight.w800,
            color: statusColor,
          ),
        ),
        const SizedBox(height: _scoreGap),
        Text(
          l.quizXpLine(result.xpAwarded, result.totalXp),
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: _statusGap),
        QuizEpisodeCard(slug: slug),
        const SizedBox(height: _statusGap),
        QuizPrimaryButton(
          l.quizReview,
          viewModel.review,
          icon: Icons.format_list_bulleted,
        ),
        const SizedBox(height: _buttonGap),
        QuizSecondaryButton(l.quizRestart, viewModel.retake, Icons.replay),
        const SizedBox(height: _buttonGap),
        QuizSecondaryButton(
          l.quizBackToQuizzes,
          () => leaveQuiz(context),
          Icons.arrow_back,
        ),
      ],
    );
  }
}
