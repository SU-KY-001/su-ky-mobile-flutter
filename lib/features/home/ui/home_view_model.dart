import 'package:flutter_riverpod/flutter_riverpod.dart';

const homeCategoryCount = 3;

/// Selected category chip index.
class HomeViewModel extends Notifier<int> {
  @override
  int build() => 0;
  void selectCategory(int index) {
    if (index >= 0 && index < homeCategoryCount) state = index;
  }
}

final homeViewModelProvider = NotifierProvider.autoDispose<HomeViewModel, int>(
  HomeViewModel.new,
);
