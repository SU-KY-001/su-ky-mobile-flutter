import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/features/home/ui/home_events_section.dart';
import 'package:su_ky_mobile/features/home/ui/home_header.dart';
import 'package:su_ky_mobile/features/home/ui/home_mission_row.dart';
import 'package:su_ky_mobile/features/home/ui/home_periods_section.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_providers.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/catalog_states.dart';
import 'package:su_ky_mobile/shared/widgets/latest_episodes_section.dart';
import 'package:su_ky_mobile/shared/widgets/series_shelf.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

const _sectionGap = 16.0;
const _bottomGap = 24.0;
const _pageInset = EdgeInsets.symmetric(horizontal: AppDesign.pagePadding);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return AppPage(
      child: ListView(
        padding: const EdgeInsets.only(bottom: _bottomGap),
        children: [
          const HomeHeader(),
          const SizedBox(height: _sectionGap),
          const HomeMissionRow(),
          Padding(
            padding: _pageInset,
            child: SectionHeading(
              l.featuredSeries,
              action: l.viewAll,
              onTap: () => context.go(AppRoutes.podcast),
            ),
          ),
          Padding(
            padding: _pageInset,
            child: CatalogAsyncView(
              value: ref.watch(seriesListProvider(null)),
              onRetry: () => ref.invalidate(seriesListProvider(null)),
              isEmpty: (items) => items.isEmpty,
              emptyMessage: l.homeSeriesEmpty,
              builder: (items) => SeriesShelf(series: items),
            ),
          ),
          const SizedBox(height: _sectionGap),
          const Padding(padding: _pageInset, child: LatestEpisodesSection()),
          const SizedBox(height: _sectionGap),
          const Padding(padding: _pageInset, child: HomeEventsSection()),
          const SizedBox(height: _sectionGap),
          const Padding(padding: _pageInset, child: HomePeriodsSection()),
        ],
      ),
    );
  }
}
