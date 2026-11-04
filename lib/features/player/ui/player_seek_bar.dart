import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/shared/audio/audio_time.dart';
import 'package:su_ky_mobile/shared/audio/playback_controller.dart';
import 'package:su_ky_mobile/shared/audio/playback_providers.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

const _trackHeight = 3.0;
const _zero = 0.0;
const _full = 1.0;

/// Seek bar. Dragging only moves a temporary local value; the seek happens on
/// release so the stream never fights the finger.
class PlayerSeekBar extends ConsumerStatefulWidget {
  const PlayerSeekBar({super.key});

  @override
  ConsumerState<PlayerSeekBar> createState() => _PlayerSeekBarState();
}

class _PlayerSeekBarState extends ConsumerState<PlayerSeekBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playbackControllerProvider);
    final durationMs = state.durationMs;
    final position = ref.watch(playbackPositionProvider).value ?? Duration.zero;
    final durationSeconds = durationMs ~/ Duration.millisecondsPerSecond;
    final ratio = durationMs <= 0
        ? _zero
        : (position.inMilliseconds / durationMs).clamp(_zero, _full).toDouble();
    final value = (_dragValue ?? ratio).clamp(_zero, _full).toDouble();
    final elapsed = _dragValue == null
        ? position.inSeconds
        : (value * durationSeconds).round();
    final remaining = durationSeconds - elapsed;
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: _trackHeight,
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: Slider(
            value: value,
            label: audioTime(elapsed),
            onChanged: durationMs <= 0
                ? null
                : (next) => setState(() => _dragValue = next),
            onChangeEnd: durationMs <= 0
                ? null
                : (next) {
                    setState(() => _dragValue = null);
                    unawaited(
                      ref
                          .read(playbackControllerProvider.notifier)
                          .seekToRatio(next),
                    );
                  },
          ),
        ),
        Row(
          children: [
            Text(
              audioTime(elapsed),
              style: context.text.labelSmall?.copyWith(color: AppDesign.muted),
            ),
            const Spacer(),
            Text(
              '-${audioTime(remaining)}',
              style: context.text.labelSmall?.copyWith(color: AppDesign.muted),
            ),
          ],
        ),
      ],
    );
  }
}
