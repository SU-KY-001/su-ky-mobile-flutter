import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/playback_controller.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode_detail.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

const _minNarrationsToSwitch = 2;
const _topGap = 12.0;

/// Segmented narration switch, shown only when the episode offers a choice.
class PlayerNarrationSwitch extends ConsumerWidget {
  const PlayerNarrationSwitch({super.key, required this.episode});

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
      child: SegmentedButton<String>(
        style: const ButtonStyle(
          minimumSize: WidgetStatePropertyAll(
            Size.fromHeight(AppDesign.tapTarget),
          ),
        ),
        showSelectedIcon: false,
        segments: [
          for (final narration in narrations)
            ButtonSegment(
              value: narration.id,
              label: Text(
                narration.type == NarrationType.firstPerson
                    ? l.narrationFirstPerson
                    : l.narrationThirdPerson,
              ),
            ),
        ],
        selected: {?selected},
        emptySelectionAllowed: true,
        onSelectionChanged: (ids) {
          if (ids.isEmpty) return;
          unawaited(
            ref
                .read(playbackControllerProvider.notifier)
                .switchNarration(ids.first),
          );
        },
      ),
    );
  }
}
