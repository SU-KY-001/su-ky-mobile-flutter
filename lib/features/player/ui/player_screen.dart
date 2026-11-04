import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/shared/audio/playback_controller.dart';
import 'package:su_ky_mobile/shared/audio/playback_state.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

import 'player_about.dart';
import 'player_controls.dart';
import 'player_cover.dart';
import 'player_header.dart';
import 'player_narration_switch.dart';
import 'player_seek_bar.dart';
import 'player_status.dart';
import 'player_track_info.dart';
import 'player_up_next_group.dart';

const _sidePadding = EdgeInsets.symmetric(horizontal: AppDesign.pagePadding);
const _blockGap = 16.0;

/// Vertical space everything except the cover needs (header, title, seek bar,
/// controls, narration switch, up-next group and gaps). The cover takes the
/// rest so the ready state fits one screen on tall phones.
const _chromeHeight = 540.0;
const _minCoverSide = 160.0;

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playbackControllerProvider);
    final episode = state.episode;
    final ready = state.status == PlaybackStatus.ready && episode != null;
    return AppPage(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxSide = constraints.maxWidth - AppDesign.pagePadding * 2;
          final side = (constraints.maxHeight - _chromeHeight).clamp(
            _minCoverSide,
            maxSide,
          );
          return SingleChildScrollView(
            padding: _sidePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PlayerHeader(episode: episode),
                if (episode != null) ...[
                  PlayerCover(episode: episode, side: side),
                  const SizedBox(height: _blockGap),
                  PlayerTrackInfo(episode: episode),
                ],
                const SizedBox(height: _blockGap),
                if (ready) ...[
                  const PlayerSeekBar(),
                  PlayerControls(state: state),
                  PlayerNarrationSwitch(episode: episode),
                  PlayerUpNextGroup(episode: episode),
                ] else
                  PlayerStatusView(state: state),
                if (episode != null) PlayerAbout(episode: episode),
                const SizedBox(height: _blockGap),
              ],
            ),
          );
        },
      ),
    );
  }
}
