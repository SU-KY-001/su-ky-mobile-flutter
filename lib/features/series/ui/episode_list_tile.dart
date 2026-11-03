import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/audio_view_model.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/mock/mock_catalog.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

/// Episode whose row shows the quiz entry point.
const _quizEpisodeIndex = 1;

class EpisodeListTile extends ConsumerWidget {
  const EpisodeListTile({super.key, required this.index});
  final int index;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final audio = ref.watch(audioViewModelProvider);
    final vm = ref.read(audioViewModelProvider.notifier);
    final current = index == audio.episode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Surface(
        selected: current,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: current ? context.accent : AppDesign.canvas,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (index + 1).toString().padLeft(2, '0'),
                    style: TextStyle(
                      color: current ? AppDesign.white : AppDesign.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        episodeTitle(l, index),
                        style: context.text.labelLarge?.copyWith(
                          color: current ? context.accent : AppDesign.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${audioTime(MockCatalog.episodeSeconds[index])}${index == 0 ? '  ·  ✓ ${l.listened}' : ''}',
                        style: context.text.labelSmall?.copyWith(
                          color: index == 0 ? Colors.teal : AppDesign.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                RoundPlay(
                  onTap: () {
                    if (current && audio.playing) {
                      vm.toggle();
                    } else {
                      vm.playEpisode(index);
                      context.push(AppRoutes.player);
                    }
                  },
                  playing: current && audio.playing,
                  filled: current,
                  size: 36,
                ),
              ],
            ),
            if (current)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: LinearProgressIndicator(
                  value: audio.progress,
                  minHeight: 3,
                  color: context.accent,
                  backgroundColor: AppDesign.line,
                ),
              ),
            if (index == _quizEpisodeIndex)
              TextButton.icon(
                onPressed: () => context.push(AppRoutes.quizFor(index)),
                icon: const Icon(Icons.quiz_outlined),
                label: Text(l.quizEntry),
              ),
          ],
        ),
      ),
    );
  }
}
