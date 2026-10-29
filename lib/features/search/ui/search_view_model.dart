import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchState {
  const SearchState({
    this.query = '',
    this.era = 0,
    this.recent = const [0, 1, 2],
  });
  final String query;
  final int era;
  final List<int> recent;
}

class SearchViewModel extends Notifier<AsyncValue<SearchState>> {
  @override
  AsyncValue<SearchState> build() => const AsyncData(SearchState());
  void query(String text) => state = AsyncData(
    SearchState(
      query: text,
      era: state.requireValue.era,
      recent: state.requireValue.recent,
    ),
  );
  void era(int index) => state = AsyncData(
    SearchState(
      query: state.requireValue.query,
      era: index,
      recent: state.requireValue.recent,
    ),
  );
  void clearHistory() => state = AsyncData(
    SearchState(
      query: state.requireValue.query,
      era: state.requireValue.era,
      recent: const [],
    ),
  );
  void removeRecent(int index) => state = AsyncData(
    SearchState(
      query: state.requireValue.query,
      era: state.requireValue.era,
      recent: state.requireValue.recent.where((item) => item != index).toList(),
    ),
  );
  bool matches(String title) => title.toLowerCase().contains(
    state.requireValue.query.trim().toLowerCase(),
  );
}

final searchViewModelProvider =
    NotifierProvider.autoDispose<SearchViewModel, AsyncValue<SearchState>>(
      SearchViewModel.new,
    );
