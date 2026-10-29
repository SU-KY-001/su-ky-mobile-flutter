import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeViewModel extends Notifier<AsyncValue<int>> {
  @override
  AsyncValue<int> build() => const AsyncData(0);
  void selectCategory(int index) {
    if (index >= 0 && index < 3) state = AsyncData(index);
  }
}

final homeViewModelProvider =
    NotifierProvider.autoDispose<HomeViewModel, AsyncValue<int>>(
      HomeViewModel.new,
    );
