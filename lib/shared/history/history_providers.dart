import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/activity/learning_activity.dart';
import '../../core/auth/signed_in.dart';
import '../../core/di/providers.dart';
import '../../core/error/result.dart';
import 'data/history_repository.dart';
import 'domain/listening_history.dart';

/// Rows the profile previews; the history screen asks for the API maximum.
const recentHistoryLimit = 5;
const fullHistoryLimit = 50;

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => ApiHistoryRepository(ref.watch(dioProvider)),
);

/// The signed-in user's recent listening. Guests get `null` without a request.
/// `learningActivityProvider` bumps after an episode or a passed quiz, which
/// rebuilds this provider so the progress and ordering stay current.
final listeningHistoryProvider = FutureProvider.autoDispose<ListeningHistory?>(
  (ref) => _load(ref, recentHistoryLimit),
);

/// Everything the history screen shows.
final fullListeningHistoryProvider =
    FutureProvider.autoDispose<ListeningHistory?>(
      (ref) => _load(ref, fullHistoryLimit),
    );

Future<ListeningHistory?> _load(Ref ref, int limit) async {
  if (!ref.watch(signedInProvider)) return null;
  ref.watch(learningActivityProvider);
  final result = await ref
      .watch(historyRepositoryProvider)
      .recent(limit: limit);
  return switch (result) {
    Ok(:final value) => value,
    Err(:final error) => throw error,
  };
}
