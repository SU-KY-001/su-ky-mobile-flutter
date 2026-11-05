import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/cover_art.dart';

import '../domain/quiz.dart' as domain;
import 'quiz_colors.dart';

const _rowPadding = EdgeInsets.symmetric(
  horizontal: AppDesign.pagePadding,
  vertical: 8,
);
const _thumbSize = 64.0;
const _thumbGap = 12.0;
const _titleGap = 4.0;
const _maxTitleLines = 2;

/// Duolingo/Kahoot list row: 64 thumb, title, "N questions · N plays", chevron.
class QuizListRow extends StatelessWidget {
  const QuizListRow({super.key, required this.card});

  final domain.QuizCard card;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return InkWell(
      onTap: () => context.push(AppRoutes.quizFor(card.episodeSlug)),
      child: Padding(
        padding: _rowPadding,
        child: Row(
          children: [
            CoverArt(
              url: card.posterUrl,
              seed: card.episodeSlug,
              height: _thumbSize,
              width: _thumbSize,
            ),
            const SizedBox(width: _thumbGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.title,
                    maxLines: _maxTitleLines,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: _titleGap),
                  Text(
                    l.quizMetaLine(
                      l.quizQuestions(card.questionCount),
                      l.quizPlays(card.plays),
                    ),
                    style: context.text.bodySmall?.copyWith(
                      color: AppDesign.muted,
                    ),
                  ),
                ],
              ),
            ),
            if (card.hasCompleted == true)
              Icon(
                Symbols.check_circle,
                fill: 1,
                color: QuizColors.green,
                semanticLabel: l.quizCompletedBadge,
              ),
            const Icon(Symbols.chevron_right, color: AppDesign.muted),
          ],
        ),
      ),
    );
  }
}
