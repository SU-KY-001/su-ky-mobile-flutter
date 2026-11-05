import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/play_gate.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode_detail.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

const _topGap = 16.0;
const _rowHeight = 56.0;

/// Quiz and next-episode rows grouped in one rounded block (Spotify "Up next").
class PlayerUpNextGroup extends ConsumerWidget {
  const PlayerUpNextGroup({super.key, required this.episode});

  final EpisodeDetail episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final next = episode.next;
    final rows = <Widget>[
      if (episode.hasQuiz)
        _Row(
          icon: Symbols.emoji_events,
          title: l.playerStartQuiz,
          onTap: () => context.push(AppRoutes.quizFor(episode.slug)),
        ),
      if (next != null)
        _Row(
          icon: Symbols.queue_music,
          title: next.title,
          caption: l.playerUpNext,
          onTap: () => unawaited(playFromUi(context, ref, next.slug)),
        ),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: _topGap),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(AppDesign.radius),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              rows[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    required this.onTap,
    this.caption,
  });

  final IconData icon;
  final String title;
  final String? caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: _rowHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDesign.pagePadding),
        child: Row(
          children: [
            Icon(icon, color: AppDesign.muted),
            const SizedBox(width: AppDesign.gap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (caption != null)
                    Text(
                      caption!,
                      style: context.text.labelSmall?.copyWith(
                        color: AppDesign.muted,
                      ),
                    ),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Symbols.chevron_right, color: AppDesign.muted),
          ],
        ),
      ),
    ),
  );
}
