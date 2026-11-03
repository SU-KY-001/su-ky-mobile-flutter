import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/features/search/ui/related_episode_tile.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/search_input.dart';
import 'package:su_ky_mobile/shared/widgets/series_card.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

import 'search_view_model.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(searchViewModelProvider).requireValue;
    final vm = ref.read(searchViewModelProvider.notifier);
    final recent = [l.recent1, l.recent2, l.recent3];
    final matches = vm.matches(
      '${l.seriesTitle} ${l.author} ${l.searchDescription}',
    );
    return AppPage(
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiniPlayer(onOpen: () => context.push(AppRoutes.player)),
          MainNavigation(
            index: 1,
            onDiscover: () => context.go(AppRoutes.home),
            onSearch: () {},
            onProfile: () => context.push(AppRoutes.login),
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
                onTap: () => context.push(AppRoutes.login),
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
            SeriesCard(
              onTap: () => context.push(AppRoutes.series),
              secondary: state.era == 2,
              large: true,
            )
          else
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l.emptyResults, textAlign: TextAlign.center),
            ),
          if (matches) ...[
            const SizedBox(height: 24),
            SectionHeading(l.relatedEpisodes, action: l.bestMatch),
            for (final index in [0, 1, 2, 3]) RelatedEpisodeTile(index: index),
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
                TextButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: Text(l.discover),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
