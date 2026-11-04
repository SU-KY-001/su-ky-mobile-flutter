import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_providers.dart';

const _iconSize = 16.0;
const _labelSize = 11.0;
const _horizontalPadding = 8.0;
const _verticalPadding = 4.0;

/// Quiz action of one series episode. The series payload has no `hasQuiz`
/// flag, so the episode detail (cached, one request per row) decides whether
/// the action appears.
class EpisodeQuizButton extends ConsumerWidget {
  const EpisodeQuizButton({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasQuiz =
        ref.watch(episodeDetailProvider(slug)).value?.hasQuiz ?? false;
    if (!hasQuiz) return const SizedBox.shrink();
    return TextButton.icon(
      onPressed: () => context.push(AppRoutes.quizFor(slug)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: _horizontalPadding,
          vertical: _verticalPadding,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: const Icon(Icons.emoji_events_outlined, size: _iconSize),
      label: Text(
        AppLocalizations.of(context).seriesStartEpisodeQuiz,
        style: const TextStyle(fontSize: _labelSize),
      ),
    );
  }
}
