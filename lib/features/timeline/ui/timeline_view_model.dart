import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Selected historical period id of the Timeline tab; null means "all
/// periods". Kept apart from the Home selection so the two tabs filter
/// independently.
class TimelineViewModel extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? periodId) => state = periodId;
}

final timelineViewModelProvider =
    NotifierProvider.autoDispose<TimelineViewModel, String?>(
      TimelineViewModel.new,
    );
