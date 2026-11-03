import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/shared/audio/playback_controller.dart';
import 'package:su_ky_mobile/shared/audio/playback_state.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

import 'player_controls.dart';
import 'player_header.dart';
import 'player_narration_chips.dart';
import 'player_next_card.dart';
import 'player_quiz_button.dart';
import 'player_seek_bar.dart';
import 'player_status.dart';
import 'player_track_info.dart';

const _contentPadding = EdgeInsets.symmetric(
  horizontal: AppDesign.pagePadding,
  vertical: 16,
);
const _artGap = 24.0;
const _sectionGap = 24.0;

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playbackControllerProvider);
    final episode = state.episode;
    final ready = state.status == PlaybackStatus.ready && episode != null;
    return AppPage(
      child: ListView(
        padding: _contentPadding,
        children: [
          const PlayerHeader(),
          if (episode != null) ...[
            const SizedBox(height: _artGap),
            PlayerTrackInfo(episode: episode),
          ],
          const SizedBox(height: _sectionGap),
          if (ready) ...[
            const PlayerSeekBar(),
            PlayerControls(state: state),
            PlayerNarrationChips(episode: episode),
            if (episode.hasQuiz) PlayerQuizButton(slug: episode.slug),
            PlayerNextCard(episode: episode),
          ] else
            PlayerStatusView(state: state),
          const SizedBox(height: _sectionGap),
        ],
      ),
    );
  }
}
