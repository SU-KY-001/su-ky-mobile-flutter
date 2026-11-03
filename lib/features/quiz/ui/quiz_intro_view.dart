import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

import 'quiz_episode_card.dart';
import 'quiz_info_tiles.dart';
import 'quiz_navigation.dart';
import 'quiz_primitives.dart';
import 'quiz_session.dart';
import 'quiz_view_model.dart';

const _cardGap = 20.0;
const _eyebrowGap = 10.0;
const _metricGap = 12.0;
const _buttonGap = 12.0;

class QuizIntroView extends StatelessWidget {
  const QuizIntroView({
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
    final quiz = session.quiz;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuizEpisodeCard(slug: slug),
        const SizedBox(height: _cardGap),
        QuizEyebrow(l.quizSubtitle.toUpperCase()),
        const SizedBox(height: _eyebrowGap),
        QuizCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuizHeading(l.quizHeading),
              const SizedBox(height: _buttonGap),
              Text(
                l.quizIntroBody,
                style: const TextStyle(height: 1.65, color: AppDesign.muted),
              ),
              const SizedBox(height: _cardGap),
              Row(
                children: [
                  Expanded(
                    child: QuizMetric(
                      icon: Icons.quiz_outlined,
                      title: l.quizQuestions(quiz.questions.length),
                      subtitle: l.quizChoiceType,
                    ),
                  ),
                  const SizedBox(width: _metricGap),
                  Expanded(
                    child: QuizMetric(
                      icon: Icons.flag_outlined,
                      title: l.quizPassScore(quiz.passScorePercent),
                      subtitle: l.quizPassScoreLabel,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: _cardGap),
        QuizPrimaryButton(l.quizStart, viewModel.start, icon: Icons.play_arrow),
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
