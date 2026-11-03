import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/play_gate.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode_detail.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

const _topGap = 24.0;
const _iconGap = 12.0;
const _lineGap = 4.0;

/// Card that starts the next episode, when the series has one.
class PlayerNextCard extends ConsumerWidget {
  const PlayerNextCard({super.key, required this.episode});

  final EpisodeDetail episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final next = episode.next;
    if (next == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: _topGap),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDesign.radius),
        onTap: () => unawaited(playFromUi(context, ref, next.slug)),
        child: Surface(
          child: Row(
            children: [
              const Icon(Icons.queue_music, color: AppDesign.muted),
              const SizedBox(width: _iconGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.playerUpNext,
                      style: context.text.labelSmall?.copyWith(
                        color: AppDesign.muted,
                        letterSpacing: .8,
                      ),
                    ),
                    const SizedBox(height: _lineGap),
                    Text(
                      next.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.play_circle_outline, color: context.accent),
            ],
          ),
        ),
      ),
    );
  }
}
