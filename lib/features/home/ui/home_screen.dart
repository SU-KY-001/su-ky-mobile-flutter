import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/features/home/ui/continue_listening_card.dart';
import 'package:su_ky_mobile/features/home/ui/home_colors.dart';
import 'package:su_ky_mobile/features/home/ui/home_header.dart';
import 'package:su_ky_mobile/features/home/ui/home_view_model.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_providers.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/catalog_states.dart';
import 'package:su_ky_mobile/shared/widgets/latest_episodes_section.dart';
import 'package:su_ky_mobile/shared/widgets/period_pills.dart';
import 'package:su_ky_mobile/shared/widgets/series_carousel.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final periodId = ref.watch(homeViewModelProvider);
    void openSearch() => context.push(AppRoutes.search);
    return AppPage(
      child: ListView(
        padding: const EdgeInsets.all(AppDesign.pagePadding),
        children: [
          const HomeHeader(),
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.weeklyMissions),
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(l.weeklyMissions),
              style: ElevatedButton.styleFrom(
                backgroundColor: HomeColors.missionButton,
                foregroundColor: AppDesign.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          InkWell(
            onTap: openSearch,
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
          PeriodPills(
            selected: periodId,
            onSelect: (id) =>
                ref.read(homeViewModelProvider.notifier).select(id),
          ),
          const SizedBox(height: 24),
          const ContinueListeningCard(),
          const SizedBox(height: 28),
          SectionHeading(l.seriesHeading, action: l.viewAll, onTap: openSearch),
          CatalogAsyncView(
            value: ref.watch(seriesListProvider(periodId)),
            onRetry: () => ref.invalidate(seriesListProvider(periodId)),
            isEmpty: (items) => items.isEmpty,
            emptyMessage: l.homeSeriesEmpty,
            builder: (items) => SeriesCarousel(series: items),
          ),
          const SizedBox(height: 28),
          const LatestEpisodesSection(),
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
