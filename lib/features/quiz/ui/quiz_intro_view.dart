import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_providers.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/cover_art.dart';

import 'quiz_bottom_bar.dart';
import 'quiz_session.dart';
import 'quiz_view_model.dart';

const _coverSize = 200.0;
const _titleSize = 22.0;
const _sectionGap = 24.0;
const _rowGap = 12.0;
const _iconGap = 12.0;

/// Plain start screen: episode cover and title, two facts, one Start button.
class QuizIntroView extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final quiz = session.quiz;
    final episode = ref.watch(episodeDetailProvider(slug)).value;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDesign.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (episode != null) ...[
                  Center(
                    child: CoverArt(
                      url: episode.seriesCoverUrl,
                      seed: episode.seriesSlug,
                      height: _coverSize,
                      width: _coverSize,
                    ),
                  ),
                  const SizedBox(height: _sectionGap),
                  Text(
                    episode.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: _titleSize,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: _sectionGap),
                ],
                _MetaRow(
                  icon: Icons.quiz_outlined,
                  text: l.quizQuestions(quiz.questions.length),
                ),
                const SizedBox(height: _rowGap),
                _MetaRow(
                  icon: Icons.flag_outlined,
                  text: l.quizPassScoreLine(quiz.passScorePercent),
                ),
              ],
            ),
          ),
        ),
        QuizBottomBar(label: l.quizStart, onPressed: viewModel.start),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: AppDesign.muted),
      const SizedBox(width: _iconGap),
      Expanded(child: Text(text, style: context.text.bodyLarge)),
    ],
  );
}
