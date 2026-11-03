import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/audio_defaults.dart';
import 'package:su_ky_mobile/shared/audio/audio_time.dart';
import 'package:su_ky_mobile/shared/audio/playback_controller.dart';
import 'package:su_ky_mobile/shared/audio/playback_state.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

const _playSize = 68.0;
const _minButtonSize = Size(44, 40);
const _restartGap = 8.0;

/// Speed, seek, play/pause, sleep timer and restart.
class PlayerControls extends ConsumerWidget {
  const PlayerControls({super.key, required this.state});

  final PlaybackState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final controller = ref.read(playbackControllerProvider.notifier);
    return Column(
      children: [
        Row(
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
              icon: const Icon(Icons.fast_rewind_rounded),
            ),
            RoundPlay(
              onTap: () => unawaited(controller.togglePlayPause()),
              playing: state.playing,
              size: _playSize,
            ),
            IconButton(
              onPressed: () =>
                  unawaited(controller.skip(AudioDefaults.seekStepSeconds)),
              tooltip: l.seekForward,
              icon: const Icon(Icons.fast_forward_rounded),
            ),
            IconButton(
              onPressed: controller.toggleSleepTimer,
              tooltip: l.sleepTimer,
              icon: Icon(
                state.sleepEnabled ? Icons.bedtime : Icons.bedtime_outlined,
                color: state.sleepEnabled ? context.accent : AppDesign.muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: _restartGap),
        TextButton.icon(
          onPressed: () => unawaited(controller.restart()),
          icon: const Icon(Icons.restart_alt),
          label: Text(l.playerRestart),
        ),
      ],
    );
  }
}
