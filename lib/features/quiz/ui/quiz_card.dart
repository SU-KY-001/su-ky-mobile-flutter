import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/cover_art.dart';

import '../domain/quiz.dart' as domain;
import 'quiz_colors.dart';

const _cardRadius = 18.0;
const _cardBorderWidth = 1.0;
const _cardPadding = 12.0;
const _coverSize = 86.0;
const _coverGap = 14.0;
const _titleGap = 5.0;
const _metaGap = 8.0;
const _metaIconSize = 14.0;
const _pillHorizontalPadding = 8.0;
const _pillVerticalPadding = 3.0;
const _pillFontSize = 10.0;
const _tagTintOpacity = .12;
const _tagLetterSpacing = .4;
const _maxTitleLines = 2;
const _maxEpisodeLines = 1;

/// Catalog tile: cover, topic, completion badge, title and counters.
class QuizCatalogCard extends StatelessWidget {
  const QuizCatalogCard({super.key, required this.card});

  final domain.QuizCard card;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Material(
      color: AppDesign.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardRadius),
        side: const BorderSide(color: AppDesign.line, width: _cardBorderWidth),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.quizFor(card.episodeSlug)),
        child: Padding(
          padding: const EdgeInsets.all(_cardPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CoverArt(
                url: card.posterUrl,
                seed: card.episodeSlug,
                height: _coverSize,
                width: _coverSize,
              ),
              const SizedBox(width: _coverGap),
              Expanded(child: _details(context, l)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _details(BuildContext context, AppLocalizations l) {
    final topic = card.topicName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: _metaGap,
          runSpacing: _metaGap,
          children: [
            if (topic != null) _Tag(label: topic, color: QuizColors.gold),
            if (card.hasCompleted == true)
              _Tag(label: l.quizCompletedBadge, color: QuizColors.green),
          ],
        ),
        const SizedBox(height: _titleGap),
        Text(
          card.title,
          maxLines: _maxTitleLines,
          overflow: TextOverflow.ellipsis,
          style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: _titleGap),
        Text(
          '${card.seriesTitle} · ${card.episodeTitle}',
          maxLines: _maxEpisodeLines,
          overflow: TextOverflow.ellipsis,
          style: context.text.bodySmall?.copyWith(color: AppDesign.muted),
        ),
        const SizedBox(height: _metaGap),
        Wrap(
          spacing: _metaGap,
          runSpacing: _titleGap,
          children: [
            _Meta(
              icon: Icons.quiz_outlined,
              label: l.quizQuestions(card.questionCount),
            ),
            _Meta(
              icon: Icons.play_circle_outline,
              label: l.quizPlays(card.plays),
            ),
          ],
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color.withValues(alpha: _tagTintOpacity),
      borderRadius: BorderRadius.circular(AppDesign.radius),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _pillHorizontalPadding,
        vertical: _pillVerticalPadding,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: _pillFontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: _tagLetterSpacing,
        ),
      ),
    ),
  );
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: _metaIconSize, color: AppDesign.muted),
      const SizedBox(width: _metaGap / 2),
      Text(
        label,
        style: context.text.labelSmall?.copyWith(color: AppDesign.muted),
      ),
    ],
  );
}
