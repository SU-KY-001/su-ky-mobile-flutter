import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/core/activity/learning_activity.dart';
import 'package:su_ky_mobile/core/error/result.dart';
import 'package:su_ky_mobile/core/logging/app_logger.dart';
import 'package:su_ky_mobile/shared/audio/playback_controller.dart';

import '../data/idempotency_key.dart';
import '../data/quiz_providers.dart';
import '../data/quiz_repository.dart';
import '../domain/quiz.dart';
import '../domain/quiz_stage.dart';
import 'quiz_session.dart';

class QuizViewModel extends AsyncNotifier<QuizSession> {
  QuizViewModel(this.slug);

  final String slug;

  @override
  Future<QuizSession> build() async {
    final quiz = await ref.watch(episodeQuizProvider(slug).future);
    return QuizSession(quiz: quiz);
  }

  void start() {
    final session = state.value;
    if (session == null || session.submitting) return;
    unawaited(ref.read(playbackControllerProvider.notifier).pause());
    state = AsyncData(
      session.copyWith(
        stage: QuizStage.question,
        index: 0,
        attemptKey: session.attemptKey ?? newIdempotencyKey(),
        clearSubmitError: true,
      ),
    );
  }

  void select(String optionId) {
    final session = state.value;
    if (session == null || session.stage != QuizStage.question) return;
    final question = session.question;
    final known = question.options.any((option) => option.id == optionId);
    if (!known) return;
    final answers = Map<String, String>.from(session.answers)
      ..[question.id] = optionId;
    state = AsyncData(session.copyWith(answers: answers));
  }

  Future<void> next() async {
    final session = state.value;
    if (session == null ||
        session.submitting ||
        session.stage != QuizStage.question ||
        session.selectedOptionId == null) {
      return;
    }
    if (!session.isLast) {
      state = AsyncData(session.copyWith(index: session.index + 1));
      return;
    }
    await _submit(session);
  }

  /// Retry entry point after a failed submission. Reuses the same key.
  Future<void> submit() async {
    final session = state.value;
    if (session == null ||
        session.submitting ||
        session.stage != QuizStage.question) {
      return;
    }
    await _submit(session);
  }

  Future<void> _submit(QuizSession session) async {
    final key = session.attemptKey;
    if (key == null || !session.allAnswered) return;
    state = AsyncData(
      session.copyWith(submitting: true, clearSubmitError: true),
    );
    final result = await ref
        .read(quizRepositoryProvider)
        .submit(
          quizId: session.quiz.id,
          idempotencyKey: key,
          answers: session.orderedAnswers,
        );
    if (!ref.mounted) return;
    final current = state.value;
    if (current == null) return;
    switch (result) {
      case Ok(:final value):
        _logMissingAnswers(current.quiz, value);
        state = AsyncData(
          current.copyWith(
            submitting: false,
            stage: QuizStage.summary,
            result: value,
          ),
        );
        ref.invalidate(quizCatalogProvider);
        if (value.isPassed) {
          ref.read(learningActivityProvider.notifier).bump();
        }
      case Err(:final error):
        state = AsyncData(
          current.copyWith(submitting: false, submitError: error),
        );
    }
  }

  /// A new attempt gets a new key; the failed one must never be reused.
  void retake() {
    final session = state.value;
    if (session == null) return;
    state = AsyncData(
      QuizSession(
        quiz: session.quiz,
        stage: QuizStage.question,
        attemptKey: newIdempotencyKey(),
      ),
    );
  }

  void review() {
    final session = state.value;
    if (session == null || session.result == null) return;
    state = AsyncData(session.copyWith(stage: QuizStage.review));
  }

  void summary() {
    final session = state.value;
    if (session == null || session.result == null) return;
    state = AsyncData(session.copyWith(stage: QuizStage.summary));
  }

  void filter(QuizFilter filter) {
    final session = state.value;
    if (session == null) return;
    state = AsyncData(session.copyWith(filter: filter));
  }

  void abandon() {
    final session = state.value;
    if (session == null) return;
    state = AsyncData(QuizSession(quiz: session.quiz));
  }

  void _logMissingAnswers(Quiz quiz, QuizResult result) {
    final answered = {for (final answer in result.answers) answer.questionId};
    for (final question in quiz.questions) {
      if (answered.contains(question.id)) continue;
      AppLogger.error(
        'Quiz result: missing answer for a question',
        error: FormatException('Missing answer for question ${question.id}'),
        stackTrace: StackTrace.current,
      );
    }
  }
}

final quizViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<QuizViewModel, QuizSession, String>(QuizViewModel.new);
