import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_providers.dart';
import 'package:su_ky_mobile/shared/catalog/domain/series.dart';

const searchDebounce = Duration(milliseconds: 400);
const searchMinChars = 2;

/// What the user typed. Debouncing and the server call live in
/// [searchResultsProvider] so typing stays instant.
class SearchViewModel extends Notifier<String> {
  @override
  String build() => '';

  void query(String text) => state = text;
}

final searchViewModelProvider =
    NotifierProvider.autoDispose<SearchViewModel, String>(SearchViewModel.new);

/// Results for the current query, or null while the query is too short.
/// Each keystroke disposes the previous run, so only the last query after the
/// debounce window reaches the API and stale responses are dropped.
final searchResultsProvider = FutureProvider.autoDispose<List<SeriesSummary>?>((
  ref,
) async {
  final query = ref.watch(searchViewModelProvider).trim();
  if (query.length < searchMinChars) return null;
  var cancelled = false;
  ref.onDispose(() => cancelled = true);
  await Future<void>.delayed(searchDebounce);
  if (cancelled) throw const _SupersededQuery();
  return ref.watch(seriesSearchProvider(query).future);
});

/// Thrown into a disposed provider run; nothing observes it.
class _SupersededQuery implements Exception {
  const _SupersededQuery();
}
