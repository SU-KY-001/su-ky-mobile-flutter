import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/error/result.dart';
import '../domain/release.dart';
import 'schedule_repository.dart';

/// Injectable "now" so the month view is deterministic in tests.
final scheduleClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

final scheduleRepositoryProvider = Provider<ScheduleRepository>(
  (ref) => ApiScheduleRepository(ref.watch(dioProvider)),
);

/// Releases of the month starting at the family key.
final scheduleProvider = FutureProvider.autoDispose
    .family<List<Release>, DateTime>((ref, month) async {
      final result = await ref.watch(scheduleRepositoryProvider).month(month);
      return switch (result) {
        Ok(:final value) => value,
        Err(:final error) => throw error,
      };
    });
