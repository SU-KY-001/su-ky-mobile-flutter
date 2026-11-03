import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:su_ky_mobile/core/error/app_exception.dart';
import 'package:su_ky_mobile/core/error/result.dart';
import 'package:su_ky_mobile/core/logging/app_logger.dart';

import '../domain/quiz.dart';
import 'quiz_attempt_codec.dart';

abstract class QuizRepository {
  Future<Result<QuizAttempt?>> latest();
  Future<Result<void>> save(QuizAttempt attempt);
}

/// Local demo history; deliberately independent of the mock login identity.
class LocalQuizRepository implements QuizRepository {
  static const _timeout = Duration(seconds: 10);
  static const _key = 'quiz.${QuizDefinition.id}.latest';

  @override
  Future<Result<QuizAttempt?>> latest() async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(_timeout);
      final raw = prefs.getString(_key);
      if (raw == null) return const Ok(null);
      return Ok(QuizAttemptCodec.decode(raw));
    } catch (error, stack) {
      AppLogger.error(
        'Cannot read quiz history',
        error: error,
        stackTrace: stack,
      );
      return Err(StorageException('Cannot read quiz history', cause: error));
    }
  }

  @override
  Future<Result<void>> save(QuizAttempt attempt) async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(_timeout);
      final success = await prefs
          .setString(_key, QuizAttemptCodec.encode(attempt))
          .timeout(_timeout);
      if (!success) throw StateError('Preference write rejected');
      return const Ok(null);
    } catch (error, stack) {
      AppLogger.error(
        'Cannot save quiz result',
        error: error,
        stackTrace: stack,
      );
      return Err(StorageException('Cannot save quiz result', cause: error));
    }
  }
}

final quizRepositoryProvider = Provider<QuizRepository>(
  (ref) => LocalQuizRepository(),
);
