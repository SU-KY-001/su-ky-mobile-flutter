import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/playback_controller.dart';
import 'package:su_ky_mobile/shared/audio/playback_providers.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/cover_art.dart';

const _rowPadding = EdgeInsets.only(left: 12, right: 4);
const _artSize = 40.0;
const _artGap = 12.0;
const _progressHeight = 2.0;
const _playIconSize = 32.0;
const _zero = 0.0;
const _full = 1.0;

/// Docked player above the tab bar (Spotify / YouTube Music pattern):
/// full width, one row, thin progress line, tap anywhere to open the player.
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
    return Material(
      color: AppDesign.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => context.push(AppRoutes.player),
            child: Padding(
              padding: _rowPadding,
              child: SizedBox(
                height: AppDesign.tapTarget + 8,
                child: Row(
                  children: [
                    CoverArt(
                      url: episode.seriesCoverUrl,
                      seed: episode.seriesSlug,
                      height: _artSize,
                      width: _artSize,
                    ),
                    const SizedBox(width: _artGap),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            episode.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            episode.seriesTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.bodySmall?.copyWith(
                              color: AppDesign.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: state.playing ? l.pause : l.play,
                      iconSize: _playIconSize,
                      constraints: const BoxConstraints.tightFor(
                        width: AppDesign.tapTarget,
                        height: AppDesign.tapTarget,
                      ),
                      onPressed: () => unawaited(controller.togglePlayPause()),
                      icon: Icon(
                        state.playing ? Symbols.pause : Symbols.play_arrow,
                        fill: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          LinearProgressIndicator(
            value: _progress(position, state.durationMs),
            minHeight: _progressHeight,
            color: context.accent,
            backgroundColor: AppDesign.line,
          ),
        ],
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
