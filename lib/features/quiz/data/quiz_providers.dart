import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/cache_for.dart';
import '../../../core/error/result.dart';
import '../domain/quiz.dart';
import 'quiz_constants.dart';
import 'quiz_repository.dart';

/// Unwraps a [Result] for `AsyncValue`: errors surface as `AsyncError` with the
/// typed `AppException`, which `appRetry` uses to decide whether to retry.
T _unwrap<T>(Result<T> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final error) => throw error,
};

/// Public catalog, optionally filtered by topic. `null` means all topics.
final quizCatalogProvider = FutureProvider.autoDispose
    .family<QuizCatalog, String?>((ref, topicId) async {
      ref.cacheFor(QuizDefaults.catalogCache);
      return _unwrap(
        await ref.watch(quizRepositoryProvider).catalog(topicId: topicId),
      );
    });

/// One quiz for an episode slug. Not cached long: a user may retake it soon.
final episodeQuizProvider = FutureProvider.autoDispose.family<Quiz, String>((
  ref,
  slug,
) async {
  return _unwrap(await ref.watch(quizRepositoryProvider).episodeQuiz(slug));
});
