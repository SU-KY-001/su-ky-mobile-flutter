import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/domain/series.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/catalog_states.dart';
import 'package:su_ky_mobile/shared/widgets/search_input.dart';
import 'package:su_ky_mobile/shared/widgets/series_card.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

import 'search_view_model.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final query = ref.watch(searchViewModelProvider);
    final vm = ref.read(searchViewModelProvider.notifier);
    final results = ref.watch(searchResultsProvider);
    return AppPage(
      child: ListView(
        padding: const EdgeInsets.all(AppDesign.pagePadding),
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.popOrGo(AppRoutes.home),
                tooltip: l.back,
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: Text(
                  l.search,
                  style: context.text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SearchInput(
            value: query,
            hint: l.bachDang,
            onChanged: vm.query,
            onVoice: () =>
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(l.voiceUnavailable))),
          ),
          const SizedBox(height: 20),
          _Results(results: results, query: query),
        ],
      ),
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({required this.results, required this.query});

  final AsyncValue<List<SeriesSummary>?> results;
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return results.when(
      skipLoadingOnReload: true,
      loading: () => const CatalogLoading(),
      error: (error, _) => CatalogError(
        error: error,
        onRetry: () => ref.invalidate(searchResultsProvider),
      ),
      data: (items) {
        if (items == null) {
          return CatalogEmpty(message: l.searchMinCharsHint);
        }
        if (items.isEmpty) return CatalogEmpty(message: l.emptyResults);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeading(l.featuredSeries),
            for (final series in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: SeriesCard(
                  series: series,
                  large: true,
                  onTap: () => context.push(AppRoutes.seriesFor(series.slug)),
                ),
              ),
          ],
        );
      },
    );
  }
}
