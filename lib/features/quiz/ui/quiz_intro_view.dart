import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

import '../domain/quiz.dart';
import 'quiz_colors.dart';
import 'quiz_episode_card.dart';
import 'quiz_info_tiles.dart';
import 'quiz_navigation.dart';
import 'quiz_primitives.dart';
import 'quiz_view_model.dart';

const _progressHeight = 6.0;
const _progressRadius = 4.0;

class QuizIntroView extends StatelessWidget {
  const QuizIntroView({super.key, required this.session, required this.vm});
  final QuizSession session;
  final QuizViewModel vm;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final attempt = session.attempt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const QuizEpisodeCard(),
        const SizedBox(height: 20),
        QuizCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuizEyebrow(l.quizSubtitle.toUpperCase()),
              const SizedBox(height: 16),
              QuizHeading(l.quizHeading),
              const SizedBox(height: 12),
              Text(
                l.quizIntro,
                style: const TextStyle(height: 1.65, color: AppDesign.muted),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: QuizMetric(
                      icon: Icons.quiz_outlined,
                      title: l.quizQuestions(QuizDefinition.questions.length),
                      subtitle: l.quizChoiceType,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuizMetric(
                      icon: Icons.schedule,
                      title: l.quizEstimate(QuizDefinition.estimatedMinutes),
                      subtitle: l.quizEstimated,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (attempt != null) ...[
          const SizedBox(height: 20),
          QuizCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    Text(
                      l.quizPrevious,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      DateFormat.yMd(
                        Localizations.localeOf(context).toLanguageTag(),
                      ).format(attempt.finishedAt.toLocal()),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                QuizHeading(
                  l.quizScore(
                    attempt.correctCount,
                    QuizDefinition.questions.length,
                  ),
                ),
                Text(l.quizAccuracy(attempt.percent)),
                const SizedBox(height: 14),
                LinearProgressIndicator(
                  value: attempt.percent / 100,
                  minHeight: _progressHeight,
                  borderRadius: BorderRadius.circular(_progressRadius),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        QuizCard(
          color: QuizColors.soft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline, color: AppDesign.red),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.quizTip,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(l.quizTipBody, style: const TextStyle(height: 1.6)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        QuizPrimaryButton(
          attempt == null ? l.quizStart : l.quizRestart,
          vm.start,
          icon: Icons.play_arrow,
        ),
        const SizedBox(height: 12),
        QuizSecondaryButton(
          l.quizReturnEpisode,
          () => leaveQuiz(context),
          Icons.menu_book_outlined,
        ),
        const SizedBox(height: 12),
        Text(
          l.quizLocalNote,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: AppDesign.muted),
        ),
        if (session.saveFailed)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(l.quizStorageError),
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}
