import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reference ViewModel: owns UI state, no `BuildContext` or widget types.
/// Replace with real feature logic.
class HomeViewModel extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}

final homeViewModelProvider = NotifierProvider.autoDispose<HomeViewModel, int>(
  HomeViewModel.new,
);
