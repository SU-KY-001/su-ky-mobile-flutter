import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/playback_controller.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode_detail.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

const _minNarrationsToSwitch = 2;
const _topGap = 24.0;
const _labelGap = 8.0;
const _chipGap = 8.0;

/// Narration switch chips, shown only when the episode offers a choice.
class PlayerNarrationChips extends ConsumerWidget {
  const PlayerNarrationChips({super.key, required this.episode});

  final EpisodeDetail episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final narrations = episode.availableNarrations;
    if (narrations.length < _minNarrationsToSwitch) {
      return const SizedBox.shrink();
    }
    final l = AppLocalizations.of(context);
    final selected = ref.watch(
      playbackControllerProvider.select((state) => state.narrationId),
    );
    return Padding(
      padding: const EdgeInsets.only(top: _topGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.narrationLabel,
            style: context.text.labelSmall?.copyWith(
              color: AppDesign.muted,
              letterSpacing: .8,
            ),
          ),
          const SizedBox(height: _labelGap),
          Wrap(
            spacing: _chipGap,
            children: [
              for (final narration in narrations)
                ChoiceChip(
                  label: Text(
                    narration.type == NarrationType.firstPerson
                        ? l.narrationFirstPerson
                        : l.narrationThirdPerson,
                  ),
                  selected: narration.id == selected,
                  onSelected: (_) => unawaited(
                    ref
                        .read(playbackControllerProvider.notifier)
                        .switchNarration(narration.id),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
