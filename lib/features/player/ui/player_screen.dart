import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/audio_view_model.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key, required this.onBack, required this.onSeries});
  final VoidCallback onBack, onSeries;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final audio = ref.watch(audioViewModelProvider);
    final vm = ref.read(audioViewModelProvider.notifier);
    return AppPage(
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDesign.pagePadding,
          vertical: 16,
        ),
        children: [
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: onBack,
                tooltip: l.close,
                icon: const Icon(Icons.keyboard_arrow_down),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      l.playingCollection,
                      style: context.text.labelSmall?.copyWith(
                        letterSpacing: .8,
                        color: AppDesign.muted,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      l.collectionTitle,
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onSeries,
                tooltip: l.detail,
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
          const SizedBox(height: 54),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Image.asset(AppDesign.cover, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 48),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  audio.episode == 1
                      ? l.playerTitle
                      : episodeTitle(l, audio.episode),
                  style: context.text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.6,
                  ),
                ),
              ),
              IconButton(
                onPressed: vm.favorite,
                tooltip: l.save,
                icon: Icon(
                  audio.favorite ? Icons.favorite : Icons.favorite_border,
                  color: audio.favorite ? context.accent : AppDesign.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              Text(
                l.bachDang,
                style: TextStyle(
                  color: context.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '·  ${l.author}',
                style: context.text.bodySmall?.copyWith(color: AppDesign.muted),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              value: audio.progress.clamp(0, 1),
              onChanged: vm.seek,
              label: audioTime(audio.position),
            ),
          ),
          Row(
            children: [
              Text(
                audioTime(audio.position),
                style: context.text.labelSmall?.copyWith(
                  color: AppDesign.muted,
                ),
              ),
              Expanded(
                child: Text(
                  '• ${l.tideRising}',
                  textAlign: TextAlign.center,
                  style: context.text.labelSmall?.copyWith(
                    color: AppDesign.muted,
                    letterSpacing: .5,
                  ),
                ),
              ),
              Text(
                '-${audioTime(audio.duration - audio.position)}',
                style: context.text.labelSmall?.copyWith(
                  color: AppDesign.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(44, 40),
                  padding: EdgeInsets.zero,
                ),
                onPressed: vm.changeSpeed,
                child: Text('${audio.speed.toStringAsFixed(1)}x'),
              ),
              IconButton(
                onPressed: () => vm.skip(-AppDesign.seekStep),
                tooltip: l.seekBack,
                icon: const Icon(Icons.replay_10_rounded),
              ),
              RoundPlay(onTap: vm.toggle, playing: audio.playing, size: 68),
              IconButton(
                onPressed: () => vm.skip(AppDesign.seekStep),
                tooltip: l.seekForward,
                icon: const Icon(Icons.forward_10_rounded),
              ),
              IconButton(
                onPressed: vm.sleep,
                tooltip: l.sleepTimer,
                icon: Icon(
                  audio.sleepEnabled ? Icons.bedtime : Icons.bedtime_outlined,
                  color: audio.sleepEnabled ? context.accent : AppDesign.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Surface(
            child: Row(
              children: [
                const Icon(Icons.queue_music, color: AppDesign.muted),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.nextEpisode,
                        style: context.text.labelSmall?.copyWith(
                          color: AppDesign.muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.nextTitle,
                        style: context.text.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(onPressed: onSeries, child: Text(l.detail)),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
