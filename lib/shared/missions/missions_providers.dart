import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/activity/learning_activity.dart';
import '../../core/auth/signed_in.dart';
import '../../core/di/providers.dart';
import '../../core/error/result.dart';
import 'data/weekly_missions_repository.dart';
import 'domain/weekly_missions.dart';

final weeklyMissionsRepositoryProvider = Provider<WeeklyMissionsRepository>(
  (ref) => ApiWeeklyMissionsRepository(ref.watch(dioProvider)),
);

/// The signed-in user's missions for the current week. Guests get `null`
/// without a request. `learningActivityProvider` bumps after an episode or a
/// passed quiz, which rebuilds this provider and refreshes XP/missions.
final weeklyMissionsProvider = FutureProvider.autoDispose<WeeklyMissions?>((
  ref,
) async {
  if (!ref.watch(signedInProvider)) return null;
  ref.watch(learningActivityProvider);
  final result = await ref.watch(weeklyMissionsRepositoryProvider).fetch();
  return switch (result) {
    Ok(:final value) => value,
    Err(:final error) => throw error,
  };
});
