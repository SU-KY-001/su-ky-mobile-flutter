import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/audio_defaults.dart';
import 'package:su_ky_mobile/shared/audio/playback_controller.dart';
import 'package:su_ky_mobile/shared/audio/playback_providers.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

const _outerPadding = EdgeInsets.fromLTRB(16, 8, 16, 4);
const _progressHeight = 2.0;
const _playSize = 36.0;
const _zero = 0.0;
const _full = 1.0;

/// Compact player above the tab bar. Tap anywhere to open the full player.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playbackControllerProvider);
    final episode = state.episode;
    if (episode == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final controller = ref.read(playbackControllerProvider.notifier);
    final position = ref.watch(playbackPositionProvider).value ?? Duration.zero;
    return Padding(
      padding: _outerPadding,
      child: Surface(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: _progress(position, state.durationMs),
              minHeight: _progressHeight,
              color: context.accent,
              backgroundColor: AppDesign.line,
            ),
            ListTile(
              dense: true,
              onTap: () => context.push(AppRoutes.player),
              leading: Icon(Icons.menu_book_outlined, color: context.accent),
              title: Text(
                episode.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(l.playerSeriesLine(episode.seriesTitle)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: l.seekBack,
                    onPressed: () => unawaited(
                      controller.skip(-AudioDefaults.seekStepSeconds),
                    ),
                    icon: const Icon(Icons.replay),
                  ),
                  RoundPlay(
                    onTap: () => unawaited(controller.togglePlayPause()),
                    playing: state.playing,
                    size: _playSize,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _progress(Duration position, int durationMs) {
    if (durationMs <= 0) return _zero;
    return (position.inMilliseconds / durationMs)
        .clamp(_zero, _full)
        .toDouble();
  }
}
