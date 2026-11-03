import 'dart:convert';

import '../domain/quiz.dart';

/// Limits applied to stored quiz JSON before it becomes a domain object.
abstract final class QuizAttemptLimits {
  static const maxOptionIndex = 3;
  static const maxElapsedSeconds = 24 * 60 * 60;
  static final isoDateTime = RegExp(
    r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?(Z|[+-]\d{2}:\d{2})?$',
  );
}

abstract final class QuizAttemptCodec {
  static const _answersKey = 'answers';
  static const _secondsKey = 'seconds';
  static const _finishedAtKey = 'finishedAt';

  static String encode(QuizAttempt attempt) => jsonEncode({
    _answersKey: attempt.answers,
    _secondsKey: attempt.elapsedSeconds,
    _finishedAtKey: attempt.finishedAt.toIso8601String(),
  });

  /// Throws [FormatException] naming the first invalid field.
  static QuizAttempt decode(String raw) {
    final Object? json = jsonDecode(raw);
    if (json is! Map<String, Object?>) {
      throw const FormatException('Quiz attempt must be a JSON object');
    }
    final answers = json[_answersKey];
    if (answers is! List<Object?> ||
        answers.length != QuizDefinition.questions.length) {
      throw const FormatException('Invalid quiz answers length');
    }
    final parsedAnswers = <int>[];
    for (final answer in answers) {
      if (answer is! int ||
          answer < 0 ||
          answer > QuizAttemptLimits.maxOptionIndex) {
        throw FormatException('Invalid quiz answer: $answer');
      }
      parsedAnswers.add(answer);
    }
    final seconds = json[_secondsKey];
    if (seconds is! int ||
        seconds < 0 ||
        seconds > QuizAttemptLimits.maxElapsedSeconds) {
      throw FormatException('Invalid quiz duration: $seconds');
    }
    final finishedAt = json[_finishedAtKey];
    if (finishedAt is! String ||
        !QuizAttemptLimits.isoDateTime.hasMatch(finishedAt)) {
      throw FormatException('Invalid quiz finish time: $finishedAt');
    }
    return QuizAttempt(
      answers: parsedAnswers,
      finishedAt: DateTime.parse(finishedAt),
      elapsedSeconds: seconds,
    );
  }
}
