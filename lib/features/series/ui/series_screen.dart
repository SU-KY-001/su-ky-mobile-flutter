import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/audio_view_model.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

class SeriesScreen extends ConsumerWidget {
  const SeriesScreen({
    super.key,
    required this.onBack,
    required this.onPlayer,
    this.onQuiz,
  });
  final ValueChanged<int>? onQuiz;
  final VoidCallback onBack, onPlayer;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final audio = ref.watch(audioViewModelProvider);
    final vm = ref.read(audioViewModelProvider.notifier);
    void notice() =>
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.demoNotice)));
    return AppPage(
      appBar: AppBar(
        leading: IconButton(
          onPressed: onBack,
          tooltip: l.back,
          icon: const Icon(Icons.chevron_left),
        ),
        title: Text(l.seriesDetail),
        actions: [
          IconButton(
            onPressed: notice,
            tooltip: l.share,
            icon: const Icon(Icons.ios_share_outlined),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                const CoverArt(height: 220),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: .08),
                          Colors.black87,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  right: 14,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          l.eraTag,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(
                            l.rating,
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 18,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.seriesTitle,
                        style: context.text.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        l.seriesAuthor,
                        style: context.text.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 16,
                color: AppDesign.muted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l.sixEpisodes,
                  style: context.text.bodySmall?.copyWith(
                    color: AppDesign.muted,
                  ),
                ),
              ),
              const Icon(Icons.schedule, size: 16, color: AppDesign.muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l.durationTotal,
                  style: context.text.bodySmall?.copyWith(
                    color: AppDesign.muted,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  l.listeners,
                  textAlign: TextAlign.end,
                  style: context.text.bodySmall?.copyWith(
                    color: AppDesign.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l.seriesDescription,
            style: context.text.bodySmall?.copyWith(height: 1.7),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    vm.startOver();
                    onPlayer();
                  },
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: Text(l.listenFromStart),
                ),
              ),
              IconButton(
                onPressed: notice,
                tooltip: l.download,
                icon: const Icon(Icons.file_download_outlined, size: 32),
              ),
              IconButton(
                onPressed: vm.save,
                tooltip: l.save,
                icon: Icon(
                  audio.saved ? Icons.bookmark : Icons.bookmark_border,
                  size: 32,
                  color: audio.saved ? context.accent : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SectionHeading(l.episodeList, action: l.sixTracks),
          for (final index in List.generate(
            AppDesign.episodeSeconds.length,
            (i) => i,
          ))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Surface(
                selected: index == audio.episode,
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
                            color: index == audio.episode
                                ? context.accent
                                : AppDesign.canvas,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            (index + 1).toString().padLeft(2, '0'),
                            style: TextStyle(
                              color: index == audio.episode
                                  ? Colors.white
                                  : AppDesign.ink,
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
                                  color: index == audio.episode
                                      ? context.accent
                                      : AppDesign.ink,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${audioTime(AppDesign.episodeSeconds[index])}${index == 0 ? '  ·  ✓ ${l.listened}' : ''}',
                                style: context.text.labelSmall?.copyWith(
                                  color: index == 0
                                      ? Colors.teal
                                      : AppDesign.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RoundPlay(
                          onTap: () {
                            if (index == audio.episode && audio.playing) {
                              vm.toggle();
                            } else {
                              vm.playEpisode(index);
                              onPlayer();
                            }
                          },
                          playing: index == audio.episode && audio.playing,
                          filled: index == audio.episode,
                          size: 36,
                        ),
                      ],
                    ),
                    if (index == audio.episode)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: LinearProgressIndicator(
                          value: audio.progress,
                          minHeight: 3,
                          color: context.accent,
                          backgroundColor: AppDesign.line,
                        ),
                      ),
                    if (index == 1 && onQuiz != null)
                      TextButton.icon(
                        onPressed: () => onQuiz!(index),
                        icon: const Icon(Icons.quiz_outlined),
                        label: Text(l.quizEntry),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
