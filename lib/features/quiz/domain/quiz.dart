import 'dart:math' as math;

const _percentBase = 100;
const _secondsPerQuestion = 30;
const _secondsPerMinute = 60;

/// One quiz entry of the public catalog (`GET /api/quizzes`).
final class QuizCard {
  const QuizCard({
    required this.id,
    required this.title,
    required this.episodeSlug,
    required this.episodeTitle,
    required this.seriesSlug,
    required this.seriesTitle,
    required this.questionCount,
    required this.plays,
    this.description,
    this.topicId,
    this.topicName,
    this.posterUrl,
    this.hasCompleted,
  });

  final String id;
  final String title;
  final String? description;
  final String episodeSlug;
  final String episodeTitle;
  final String seriesSlug;
  final String seriesTitle;
  final String? topicId;
  final String? topicName;
  final String? posterUrl;
  final int questionCount;
  final int plays;

  /// `null` for guests; `true` once the user has submitted any attempt.
  final bool? hasCompleted;
}

/// The first page of the quiz catalog. The API is not paginated in the app.
final class QuizCatalog {
  const QuizCatalog({required this.items, required this.total});

  final List<QuizCard> items;
  final int total;

  bool get isEmpty => items.isEmpty;
}

final class QuizOption {
  const QuizOption({required this.id, required this.label, required this.text});

  final String id;
  final String label;
  final String text;
}

final class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.text,
    required this.sortOrder,
    required this.options,
  });

  final String id;
  final String text;
  final int sortOrder;
  final List<QuizOption> options;
}

/// One quiz without correct answers: the API hides them until submission.
final class Quiz {
  const Quiz({
    required this.id,
    required this.episodeId,
    required this.passScorePercent,
    required this.questions,
  });

  final String id;
  final String episodeId;
  final int passScorePercent;
  final List<QuizQuestion> questions;

  /// Fewest correct answers that reach [passScorePercent] (rounded up).
  int get requiredCorrect =>
      (questions.length * passScorePercent + _percentBase - 1) ~/ _percentBase;

  /// Rough time to answer, never below one minute.
  int get estimatedMinutes => math.max(
    1,
    (questions.length * _secondsPerQuestion + _secondsPerMinute - 1) ~/
        _secondsPerMinute,
  );

  QuizQuestion? questionById(String id) {
    for (final question in questions) {
      if (question.id == id) return question;
    }
    return null;
  }
}

/// One submitted answer. [optionId] is never null from the UI, which requires
/// a choice on every question before submitting.
final class QuizAnswer {
  const QuizAnswer({required this.questionId, required this.optionId});

  final String questionId;
  final String optionId;
}

final class QuizAnswerResult {
  const QuizAnswerResult({
    required this.questionId,
    required this.correctOptionId,
    required this.isCorrect,
    this.selectedOptionId,
    this.explanation,
  });

  final String questionId;
  final String? selectedOptionId;
  final String correctOptionId;
  final bool isCorrect;
  final String? explanation;
}

/// Server verdict of a submitted attempt.
final class QuizResult {
  const QuizResult({
    required this.scorePercent,
    required this.isPassed,
    required this.xpAwarded,
    required this.totalXp,
    required this.answers,
  });

  final int scorePercent;
  final bool isPassed;
  final int xpAwarded;
  final int totalXp;
  final List<QuizAnswerResult> answers;
}

/// One reviewed question: the quiz content plus the server verdict.
final class QuizReviewEntry {
  const QuizReviewEntry({required this.question, required this.answer});

  final QuizQuestion question;
  final QuizAnswerResult answer;

  QuizOption? get selectedOption => _optionById(answer.selectedOptionId);

  QuizOption? get correctOption => _optionById(answer.correctOptionId);

  QuizOption? _optionById(String? id) {
    if (id == null) return null;
    for (final option in question.options) {
      if (option.id == id) return option;
    }
    return null;
  }
}
