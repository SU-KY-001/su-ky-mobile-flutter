import 'package:su_ky_mobile/core/error/app_exception.dart';

import '../domain/quiz.dart';
import '../domain/quiz_stage.dart';

/// Immutable state of one quiz attempt.
final class QuizSession {
  QuizSession({
    required this.quiz,
    this.stage = QuizStage.introduction,
    this.index = 0,
    Map<String, String> answers = const {},
    this.attemptKey,
    this.submitting = false,
    this.submitError,
    this.result,
    this.filter = QuizFilter.all,
  }) : answers = Map.unmodifiable(answers);

  final Quiz quiz;
  final QuizStage stage;
  final int index;

  /// `questionId -> optionId` for questions answered so far.
  final Map<String, String> answers;

  /// Kept from the first submit until a retake, so retries reuse it.
  final String? attemptKey;
  final bool submitting;
  final AppException? submitError;
  final QuizResult? result;
  final QuizFilter filter;

  QuizQuestion get question => quiz.questions[index];

  String? get selectedOptionId => answers[question.id];

  bool get isLast => index >= quiz.questions.length - 1;

  int get total => quiz.questions.length;

  /// Every answered question in `sortOrder` (the parsed order), which is the
  /// order the API expects.
  List<QuizAnswer> get orderedAnswers {
    final list = <QuizAnswer>[];
    for (final item in quiz.questions) {
      final optionId = answers[item.id];
      if (optionId == null) continue;
      list.add(QuizAnswer(questionId: item.id, optionId: optionId));
    }
    return list;
  }

  bool get allAnswered => orderedAnswers.length == quiz.questions.length;

  int get correctCount {
    final answers = result?.answers;
    if (answers == null) return 0;
    return answers.where((answer) => answer.isCorrect).length;
  }

  List<QuizReviewEntry> get reviewEntries {
    final verdict = result;
    if (verdict == null) return const [];
    final byQuestion = {
      for (final answer in verdict.answers) answer.questionId: answer,
    };
    return [
      for (final item in quiz.questions)
        if (byQuestion[item.id] != null)
          QuizReviewEntry(question: item, answer: byQuestion[item.id]!),
    ];
  }

  QuizSession copyWith({
    QuizStage? stage,
    int? index,
    Map<String, String>? answers,
    String? attemptKey,
    bool? submitting,
    AppException? submitError,
    bool clearSubmitError = false,
    QuizResult? result,
    QuizFilter? filter,
  }) => QuizSession(
    quiz: quiz,
    stage: stage ?? this.stage,
    index: index ?? this.index,
    answers: answers ?? this.answers,
    attemptKey: attemptKey ?? this.attemptKey,
    submitting: submitting ?? this.submitting,
    submitError: clearSubmitError ? null : submitError ?? this.submitError,
    result: result ?? this.result,
    filter: filter ?? this.filter,
  );
}
