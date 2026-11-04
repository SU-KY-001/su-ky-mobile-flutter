import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/activity/learning_activity.dart';
import '../../core/auth/signed_in.dart';
import '../../core/di/providers.dart';
import '../../core/error/result.dart';
import 'data/history_repository.dart';
import 'domain/listening_history.dart';

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => ApiHistoryRepository(ref.watch(dioProvider)),
);

/// The signed-in user's recent listening. Guests get `null` without a request.
/// `learningActivityProvider` bumps after an episode or a passed quiz, which
/// rebuilds this provider so the progress and ordering stay current.
final listeningHistoryProvider = FutureProvider.autoDispose<ListeningHistory?>((
  ref,
) async {
  if (!ref.watch(signedInProvider)) return null;
  ref.watch(learningActivityProvider);
  final result = await ref.watch(historyRepositoryProvider).recent();
  return switch (result) {
    Ok(:final value) => value,
    Err(:final error) => throw error,
  };
});
