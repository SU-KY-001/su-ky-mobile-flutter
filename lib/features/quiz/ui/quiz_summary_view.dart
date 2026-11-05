import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

import 'quiz_bottom_bar.dart';
import 'quiz_colors.dart';
import 'quiz_navigation.dart';
import 'quiz_session.dart';
import 'quiz_view_model.dart';

const _scoreSize = 72.0;
const _statusSize = 22.0;
const _topGap = 48.0;
const _lineGap = 12.0;

/// Duolingo "Lesson complete": big score, status, XP, Continue.
class QuizSummaryView extends StatelessWidget {
  const QuizSummaryView({
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
    final statusColor = result.isPassed ? QuizColors.green : AppDesign.red;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDesign.pagePadding),
            child: Column(
              children: [
                const SizedBox(height: _topGap),
                Text(
                  l.quizScoreFraction(session.correctCount, session.total),
                  style: const TextStyle(
                    fontSize: _scoreSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: _lineGap),
                Text(
                  result.isPassed ? l.quizPassed : l.quizFailed,
                  style: TextStyle(
                    fontSize: _statusSize,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: _lineGap),
                Text(
                  l.quizXpLine(result.xpAwarded, result.totalXp),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
        QuizBottomBar(
          label: l.quizDone,
          onPressed: () => leaveQuiz(context),
          secondary: [
            TextButton(onPressed: viewModel.review, child: Text(l.quizReview)),
            TextButton(onPressed: viewModel.retake, child: Text(l.quizRestart)),
          ],
        ),
      ],
    );
  }
}
