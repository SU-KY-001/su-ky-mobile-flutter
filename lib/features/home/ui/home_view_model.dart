import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Selected historical period id; null means "all periods".
class HomeViewModel extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? periodId) => state = periodId;
}

final homeViewModelProvider =
    NotifierProvider.autoDispose<HomeViewModel, String?>(HomeViewModel.new);
