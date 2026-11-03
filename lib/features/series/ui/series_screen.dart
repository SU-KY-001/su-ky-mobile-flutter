import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/features/series/ui/episode_list_tile.dart';
import 'package:su_ky_mobile/features/series/ui/series_hero.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/audio_view_model.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/mock/mock_catalog.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

class SeriesScreen extends ConsumerWidget {
  const SeriesScreen({super.key});
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
          onPressed: () => context.popOrGo(AppRoutes.home),
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
          const SeriesHero(),
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
                    context.push(AppRoutes.player);
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
          for (
            var index = 0;
            index < MockCatalog.episodeSeconds.length;
            index++
          )
            EpisodeListTile(index: index),
        ],
      ),
    );
  }
}
