import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/audio_view_model.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/search_input.dart';
import 'package:su_ky_mobile/shared/widgets/series_card.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

import 'search_view_model.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({
    super.key,
    required this.onHome,
    required this.onProfile,
    required this.onSeries,
    required this.onPlayer,
  });
  final VoidCallback onHome, onProfile, onSeries, onPlayer;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(searchViewModelProvider).requireValue;
    final vm = ref.read(searchViewModelProvider.notifier);
    final audio = ref.watch(audioViewModelProvider);
    final recent = [l.recent1, l.recent2, l.recent3];
    final matches = vm.matches(
      '${l.seriesTitle} ${l.author} ${l.searchDescription}',
    );
    return AppPage(
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiniPlayer(onOpen: onPlayer),
          MainNavigation(
            index: 1,
            onDiscover: onHome,
            onSearch: () {},
            onProfile: onProfile,
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.all(AppDesign.pagePadding),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.brandAudio,
                      style: context.text.labelSmall?.copyWith(
                        color: context.accent,
                        letterSpacing: .8,
                      ),
                    ),
                    Text(
                      l.search,
                      style: context.text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(l.noNotifications))),
                tooltip: l.notifications,
                icon: const Icon(Icons.notifications_none),
              ),
              InkWell(
                onTap: onProfile,
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: AppDesign.tint,
                  child: Text(
                    l.avatarInitials,
                    style: TextStyle(color: context.accent, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SearchInput(
            value: state.query,
            hint: l.bachDang,
            onChanged: vm.query,
            onVoice: () =>
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(l.voiceUnavailable))),
          ),
          const SizedBox(height: 20),
          SectionHeading(l.timeline, action: l.allEras, onTap: () => vm.era(0)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final (index, name) in [
                  l.all,
                  l.southernHan,
                  l.lyTran,
                ].indexed)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      label: Text(
                        name,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: state.era == index
                              ? Colors.white
                              : AppDesign.ink,
                        ),
                      ),
                      selected: state.era == index,
                      onSelected: (_) => vm.era(index),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionHeading(
            l.recentSearches,
            action: l.clearHistory,
            onTap: vm.clearHistory,
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final index in state.recent)
                InputChip(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    recent[index],
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppDesign.ink,
                    ),
                  ),
                  onDeleted: () => vm.removeRecent(index),
                  onPressed: () => vm.query(recent[index]),
                ),
            ],
          ),
          const SizedBox(height: 24),
          SectionHeading(
            l.featuredSeries,
            action: matches ? l.resultsCount : null,
          ),
          if (matches)
            SeriesCard(onTap: onSeries, secondary: state.era == 2, large: true)
          else
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l.emptyResults, textAlign: TextAlign.center),
            ),
          if (matches) ...[
            const SizedBox(height: 24),
            SectionHeading(l.relatedEpisodes, action: l.bestMatch),
            for (final index in [0, 1, 2, 3])
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Surface(
                  selected: index == audio.episode,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CoverArt(
                        path: index.isEven
                            ? AppDesign.cover
                            : AppDesign.secondCover,
                        width: 48,
                        height: 54,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: onSeries,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (index == audio.episode)
                                Text(
                                  l.listeningBadge,
                                  style: context.text.labelSmall?.copyWith(
                                    color: context.accent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              Text(
                                episodeTitle(l, index),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(l.bachDang, style: context.text.bodySmall),
                              Text(
                                audioTime(AppDesign.episodeSeconds[index]),
                                style: context.text.labelSmall?.copyWith(
                                  color: AppDesign.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      RoundPlay(
                        onTap: () {
                          ref
                              .read(audioViewModelProvider.notifier)
                              .playEpisode(index);
                          onPlayer();
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
          const SizedBox(height: 14),
          Surface(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.explorePrompt,
                        style: context.text.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(l.exploreDescription, style: context.text.bodySmall),
                    ],
                  ),
                ),
                TextButton(onPressed: onHome, child: Text(l.discover)),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
