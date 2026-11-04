import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/schedule_providers.dart';

final scheduleViewModelProvider =
    NotifierProvider.autoDispose<ScheduleViewModel, DateTime>(
      ScheduleViewModel.new,
    );

/// The month currently shown by the schedule, always its first local day.
class ScheduleViewModel extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = ref.read(scheduleClockProvider)();
    return DateTime(now.year, now.month);
  }

  void previous() => state = DateTime(state.year, state.month - 1);

  void next() => state = DateTime(state.year, state.month + 1);
}
