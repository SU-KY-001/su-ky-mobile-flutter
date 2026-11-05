import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Selected historical period id of the Timeline tab; null means "all
/// periods". Shared so Home can open the tab with a period already chosen.
/// Not autoDispose: Home sets it before the Timeline tab has ever been built.
class TimelineViewModel extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? periodId) => state = periodId;
}

final timelineViewModelProvider = NotifierProvider<TimelineViewModel, String?>(
  TimelineViewModel.new,
);
