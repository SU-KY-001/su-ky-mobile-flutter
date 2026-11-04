import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/features/podcast/ui/podcast_episode_row.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_providers.dart';
import 'package:su_ky_mobile/shared/widgets/catalog_states.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

/// "Tập mới phát hành" as list rows (Apple Podcasts "Latest episodes").
class PodcastLatestSection extends ConsumerWidget {
  const PodcastLatestSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(l.newEpisodes),
        CatalogAsyncView(
          value: ref.watch(latestEpisodesProvider),
          onRetry: () => ref.invalidate(latestEpisodesProvider),
          isEmpty: (items) => items.isEmpty,
          emptyMessage: l.podcastEmptyMessage,
          builder: (items) => Column(
            children: [
              for (final latest in items) PodcastEpisodeRow(latest: latest),
            ],
          ),
        ),
      ],
    );
  }
}
