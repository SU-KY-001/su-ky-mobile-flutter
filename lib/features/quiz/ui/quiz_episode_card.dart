import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/widgets/cover_art.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

import 'quiz_colors.dart';
import 'quiz_primitives.dart';

const _coverSize = 72.0;

class QuizEpisodeCard extends StatelessWidget {
  const QuizEpisodeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return QuizCard(
      child: Row(
        children: [
          const CoverArt(height: _coverSize, width: _coverSize),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.bachDang.toUpperCase(),
                  style: const TextStyle(
                    color: QuizColors.gold,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l.playerTitle,
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
