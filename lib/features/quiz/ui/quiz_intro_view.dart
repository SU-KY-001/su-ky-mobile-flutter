import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:su_ky_mobile/features/quiz/data/quiz_providers.dart';
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

/// Start screen: cover, title, pass rules, estimated time, a hint, Start.
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
    final card = ref
        .watch(quizCatalogProvider(null))
        .value
        ?.items
        .where((c) => c.episodeSlug == slug)
        .firstOrNull;
    final episode = ref.watch(episodeDetailProvider(slug)).value;
    final title = card?.title ?? episode?.title;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDesign.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null) ...[
                  Center(
                    child: CoverArt(
                      url: card?.posterUrl,
                      seed: slug,
                      height: _coverSize,
                      width: _coverSize,
                    ),
                  ),
                  const SizedBox(height: _sectionGap),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: _titleSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: _sectionGap),
                ],
                _MetaRow(
                  icon: Symbols.quiz,
                  text: l.quizQuestions(quiz.questions.length),
                ),
                const SizedBox(height: _rowGap),
                _MetaRow(
                  icon: Symbols.flag,
                  text: l.quizPassScoreLine(quiz.passScorePercent),
                ),
                const SizedBox(height: _rowGap),
                _MetaRow(
                  icon: Symbols.check_circle,
                  text: l.quizPassNeededLine(
                    quiz.requiredCorrect,
                    quiz.questions.length,
                  ),
                ),
                const SizedBox(height: _rowGap),
                _MetaRow(
                  icon: Symbols.timer,
                  text: l.quizDurationLine(quiz.estimatedMinutes),
                ),
                const SizedBox(height: _sectionGap),
                Text(
                  l.quizIntroHint,
                  style: context.text.bodyMedium?.copyWith(
                    color: AppDesign.muted,
                  ),
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
