import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

import '../domain/quiz.dart';
import 'quiz_colors.dart';
import 'quiz_episode_card.dart';
import 'quiz_info_tiles.dart';
import 'quiz_navigation.dart';
import 'quiz_primitives.dart';
import 'quiz_view_model.dart';

const _secondsPerMinute = 60;
const _trophySize = 100.0;

class QuizSummaryView extends StatelessWidget {
  const QuizSummaryView({super.key, required this.session, required this.vm});
  final QuizSession session;
  final QuizViewModel vm;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = session;
    final attempt = s.attempt!;
    final count = QuizDefinition.questions.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        const Icon(
          Icons.workspace_premium_outlined,
          size: _trophySize,
          color: QuizColors.gold,
        ),
        const SizedBox(height: 20),
        Text(
          l.quizScore(attempt.correctCount, count),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          l.quizAccuracy(attempt.percent),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: QuizColors.gold,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          attempt.percent >= QuizDefinition.excellentPercent
              ? l.quizExcellent
              : l.quizEncourage,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: AppDesign.red,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l.quizResultBody,
          textAlign: TextAlign.center,
          style: const TextStyle(height: 1.7, color: AppDesign.muted),
        ),
        const SizedBox(height: 28),
        QuizCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              QuizHeading(l.quizStatistics, size: 20),
              const SizedBox(height: 16),
              QuizStat(
                icon: Icons.schedule,
                label: l.quizElapsed,
                value: l.quizDuration(
                  attempt.elapsedSeconds ~/ _secondsPerMinute,
                  attempt.elapsedSeconds % _secondsPerMinute,
                ),
              ),
              QuizStat(
                icon: Icons.check_circle_outline,
                label: l.quizRightCount,
                value: '${attempt.correctCount}',
                color: QuizColors.green,
              ),
              QuizStat(
                icon: Icons.error_outline,
                label: l.quizWrongCount,
                value: '${count - attempt.correctCount}',
                color: AppDesign.red,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const QuizEpisodeCard(),
        const SizedBox(height: 24),
        if (s.saving) ...[
          const LinearProgressIndicator(),
          const SizedBox(height: 8),
          Text(l.quizSaving),
          const SizedBox(height: 12),
        ],
        if (s.saveFailed) ...[
          Text(l.quizStorageError),
          TextButton(
            onPressed: s.saving ? null : vm.retrySave,
            child: Text(l.quizRetrySave),
          ),
        ],
        QuizPrimaryButton(
          l.quizReview,
          vm.review,
          icon: Icons.format_list_bulleted,
        ),
        const SizedBox(height: 12),
        QuizSecondaryButton(
          l.quizRestart,
          s.saving ? null : vm.start,
          Icons.replay,
        ),
        const SizedBox(height: 12),
        QuizSecondaryButton(
          l.quizReturnEpisode,
          () => leaveQuiz(context),
          Icons.arrow_back,
        ),
        const SizedBox(height: 16),
        Text(
          l.quizLocalNote,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: AppDesign.muted),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
