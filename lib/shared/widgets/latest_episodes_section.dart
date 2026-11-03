import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_providers.dart';
import 'package:su_ky_mobile/shared/widgets/catalog_states.dart';
import 'package:su_ky_mobile/shared/widgets/latest_episode_tile.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

/// "Latest episodes" block shared by Home and Podcast. Tapping opens the
/// series (real playback arrives with the audio engine).
class LatestEpisodesSection extends ConsumerWidget {
  const LatestEpisodesSection({super.key});

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
              for (final latest in items)
                LatestEpisodeTile(
                  latest: latest,
                  onTap: () =>
                      context.push(AppRoutes.seriesFor(latest.seriesSlug)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
