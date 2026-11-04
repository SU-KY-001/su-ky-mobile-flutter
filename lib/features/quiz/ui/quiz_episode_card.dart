import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_providers.dart';
import 'package:su_ky_mobile/shared/widgets/cover_art.dart';

import 'quiz_colors.dart';
import 'quiz_primitives.dart';

const _coverSize = 72.0;
const _coverGap = 14.0;
const _titleGap = 6.0;
const _seriesFontSize = 11.0;

/// Episode header of the quiz. Hidden until the episode detail is available.
class QuizEpisodeCard extends ConsumerWidget {
  const QuizEpisodeCard({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episode = ref.watch(episodeDetailProvider(slug)).value;
    if (episode == null) return const SizedBox.shrink();
    return QuizCard(
      child: Row(
        children: [
          CoverArt(
            url: episode.seriesCoverUrl,
            seed: episode.seriesSlug,
            height: _coverSize,
            width: _coverSize,
          ),
          const SizedBox(width: _coverGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  episode.seriesTitle.toUpperCase(),
                  style: const TextStyle(
                    color: QuizColors.gold,
                    fontWeight: FontWeight.w700,
                    fontSize: _seriesFontSize,
                  ),
                ),
                const SizedBox(height: _titleGap),
                Text(
                  episode.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
