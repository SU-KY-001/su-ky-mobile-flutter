import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/features/search/ui/series_result_row.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/domain/series.dart';
import 'package:su_ky_mobile/shared/widgets/catalog_states.dart';
import 'package:su_ky_mobile/shared/widgets/search_input.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

import 'search_view_model.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final query = ref.watch(searchViewModelProvider);
    final vm = ref.read(searchViewModelProvider.notifier);
    return AppPage(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.popOrGo(AppRoutes.home),
          tooltip: l.back,
          icon: const Icon(Symbols.arrow_back),
        ),
        title: SearchInput(
          value: query,
          hint: l.searchHint,
          onChanged: vm.query,
        ),
      ),
      child: _Results(results: ref.watch(searchResultsProvider)),
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({required this.results});

  final AsyncValue<List<SeriesSummary>?> results;

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
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, index) => SeriesResultRow(
            series: items[index],
            onTap: () => context.push(AppRoutes.seriesFor(items[index].slug)),
          ),
        );
      },
    );
  }
}
