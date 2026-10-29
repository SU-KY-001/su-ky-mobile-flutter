import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/audio_view_model.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/series_card.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

import 'home_view_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
    required this.onSearch,
    required this.onSeries,
    required this.onPlayer,
    required this.onProfile,
  });
  final VoidCallback onSearch, onSeries, onPlayer, onProfile;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final audio = ref.watch(audioViewModelProvider);
    final vm = ref.read(audioViewModelProvider.notifier);
    final category = ref.watch(homeViewModelProvider).asData?.value ?? 0;
    final titles = [l.damTitle, l.meTitle, l.lyTitle];
    final subtitles = [l.damSubtitle, l.meSubtitle, l.lySubtitle];
    final eras = [l.damEra, l.meEra, l.lyEra];
    return AppPage(
      bottom: MainNavigation(
        index: 0,
        onDiscover: () {},
        onSearch: onSearch,
        onProfile: onProfile,
      ),
      child: ListView(
        padding: const EdgeInsets.all(AppDesign.pagePadding),
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: context.accent,
                radius: 17,
                child: const Icon(
                  Icons.auto_stories_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.appName,
                      style: context.text.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      l.audioHistory,
                      style: context.text.labelSmall?.copyWith(
                        letterSpacing: 1.4,
                        color: AppDesign.muted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onProfile,
                icon: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppDesign.tint,
                  child: Text(l.initials, style: context.text.labelMedium),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Divider(),
          ),
          Text(
            l.homeHeading,
            style: context.text.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.homeSubtitle,
            style: context.text.bodyMedium?.copyWith(color: AppDesign.muted),
          ),
          const SizedBox(height: 18),
          InkWell(
            onTap: onSearch,
            borderRadius: BorderRadius.circular(14),
            child: Surface(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 20, color: AppDesign.muted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l.searchHint,
                      style: context.text.bodySmall?.copyWith(
                        color: AppDesign.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final (index, name) in [
                  l.all,
                  l.battles,
                  l.people,
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
                          color: category == index
                              ? Colors.white
                              : AppDesign.ink,
                        ),
                      ),
                      selected: category == index,
                      onSelected: (_) => ref
                          .read(homeViewModelProvider.notifier)
                          .selectCategory(index),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      l.continueListening,
                      style: context.text.labelSmall?.copyWith(
                        color: context.accent,
                        letterSpacing: .8,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${audioTime(audio.position)} / ${audioTime(audio.duration)}',
                      style: context.text.labelSmall?.copyWith(
                        color: AppDesign.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: onPlayer,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.resumeTitle,
                              style: context.text.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l.resumeSubtitle,
                              style: context.text.bodySmall?.copyWith(
                                color: AppDesign.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    RoundPlay(
                      onTap: () {
                        vm.playEpisode(audio.episode);
                        onPlayer();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: audio.progress,
                    minHeight: 4,
                    color: context.accent,
                    backgroundColor: AppDesign.line,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SectionHeading(l.seriesHeading, action: l.viewAll, onTap: onSearch),
          SizedBox(
            height: 264,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: category == 2 ? 1 : 2,
              separatorBuilder: (_, _) => const SizedBox(width: 16),
              itemBuilder: (_, index) => SizedBox(
                width: 224,
                child: SeriesCard(
                  onTap: index == 0 ? onSeries : onSearch,
                  secondary: index == 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          SectionHeading(l.newEpisodes, action: l.today, onTap: onSearch),
          for (final index in [0, 1, 2])
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Surface(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CoverArt(
                      path: AppDesign.thumbnails[index],
                      height: 48,
                      width: 48,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            eras[index],
                            style: context.text.labelSmall?.copyWith(
                              color: AppDesign.muted,
                              fontSize: 9,
                            ),
                          ),
                          Text(
                            titles[index],
                            style: context.text.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            subtitles[index],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.bodySmall?.copyWith(
                              color: AppDesign.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RoundPlay(
                      onTap: () {
                        vm.playEpisode(index);
                        onPlayer();
                      },
                      filled: false,
                      size: 36,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 34),
          Surface(
            selected: true,
            child: Column(
              children: [
                Text(
                  l.quote,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontStyle: FontStyle.italic,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l.quoteAuthor,
                  style: context.text.labelSmall?.copyWith(
                    color: AppDesign.muted,
                    letterSpacing: .5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 56),
        ],
      ),
    );
  }
}
