import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/audio_defaults.dart';
import 'package:su_ky_mobile/shared/audio/audio_time.dart';
import 'package:su_ky_mobile/shared/audio/playback_controller.dart';
import 'package:su_ky_mobile/shared/audio/playback_state.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

const _playSize = 72.0;
const _playIconSize = 40.0;
const _minButtonSize = Size.square(AppDesign.tapTarget);

/// Speed, -15, play/pause (replay when finished), +15 and sleep timer.
class PlayerControls extends ConsumerWidget {
  const PlayerControls({super.key, required this.state});

  final PlaybackState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final controller = ref.read(playbackControllerProvider.notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: _minButtonSize,
            padding: EdgeInsets.zero,
          ),
          onPressed: () => unawaited(controller.cycleSpeed()),
          child: Text(l.playbackSpeed(audioSpeed(state.speed))),
        ),
        IconButton(
          onPressed: () =>
              unawaited(controller.skip(-AudioDefaults.seekStepSeconds)),
          tooltip: l.seekBack,
          icon: const Icon(Symbols.fast_rewind),
        ),
        IconButton.filled(
          style: IconButton.styleFrom(
            minimumSize: const Size.square(_playSize),
            backgroundColor: context.accent,
            foregroundColor: AppDesign.white,
          ),
          iconSize: _playIconSize,
          tooltip: _playTooltip(l),
          onPressed: () => unawaited(controller.togglePlayPause()),
          icon: Icon(_playIcon, fill: 1),
        ),
        IconButton(
          onPressed: () =>
              unawaited(controller.skip(AudioDefaults.seekStepSeconds)),
          tooltip: l.seekForward,
          icon: const Icon(Symbols.fast_forward),
        ),
        IconButton(
          onPressed: controller.toggleSleepTimer,
          tooltip: l.sleepTimer,
          icon: Icon(
            Symbols.bedtime,
            fill: state.sleepEnabled ? 1 : 0,
            color: state.sleepEnabled ? context.accent : AppDesign.muted,
          ),
        ),
      ],
    );
  }

  IconData get _playIcon {
    if (state.completed) return Symbols.replay;
    return state.playing ? Symbols.pause : Symbols.play_arrow;
  }

  String _playTooltip(AppLocalizations l) {
    if (state.completed) return l.playerReplay;
    return state.playing ? l.pause : l.play;
  }
}
