import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode_detail.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

const _actionExtent = AppDesign.tapTarget;

enum _MenuAction { quiz, series }

/// Chevron-down, "playing from" + series title, and the overflow menu.
class PlayerHeader extends StatelessWidget {
  const PlayerHeader({super.key, this.episode});

  final EpisodeDetail? episode;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final current = episode;
    return SizedBox(
      height: kToolbarHeight,
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.popOrGo(AppRoutes.home),
            tooltip: l.close,
            icon: const Icon(Icons.keyboard_arrow_down),
          ),
          Expanded(
            child: current == null
                ? const SizedBox.shrink()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l.playerFromSeries,
                        style: context.text.labelSmall?.copyWith(
                          color: AppDesign.muted,
                        ),
                      ),
                      Text(
                        current.seriesTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
          if (current == null)
            const SizedBox(width: _actionExtent)
          else
            PopupMenuButton<_MenuAction>(
              tooltip: l.playerMore,
              onSelected: (action) => switch (action) {
                _MenuAction.quiz => context.push(
                  AppRoutes.quizFor(current.slug),
                ),
                _MenuAction.series => context.push(
                  AppRoutes.seriesFor(current.seriesSlug),
                ),
              },
              itemBuilder: (_) => [
                if (current.hasQuiz)
                  PopupMenuItem(
                    value: _MenuAction.quiz,
                    child: Text(l.playerStartQuiz),
                  ),
                PopupMenuItem(
                  value: _MenuAction.series,
                  child: Text(l.playerAboutSeries),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
