import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:su_ky_mobile/core/error/app_exception.dart';
import 'package:su_ky_mobile/core/error/result.dart';
import 'package:su_ky_mobile/core/logging/app_logger.dart';

import '../domain/quiz.dart';

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
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      final answers = decoded['answers'];
      final seconds = decoded['seconds'];
      final date = decoded['finishedAt'];
      if (answers is! List ||
          answers.length != QuizDefinition.questions.length ||
          answers.any((a) => a is! int || a < 0 || a > 3) ||
          seconds is! int ||
          seconds < 0 ||
          date is! String) {
        throw const FormatException('Invalid quiz attempt');
      }
      return Ok(
        QuizAttempt(
          answers: answers.cast<int>(),
          finishedAt: DateTime.parse(date),
          elapsedSeconds: seconds,
        ),
      );
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
          .setString(
            _key,
            jsonEncode({
              'answers': attempt.answers,
              'seconds': attempt.elapsedSeconds,
              'finishedAt': attempt.finishedAt.toIso8601String(),
            }),
          )
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
