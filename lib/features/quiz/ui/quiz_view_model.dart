import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/core/error/result.dart';
import 'package:su_ky_mobile/shared/audio/audio_view_model.dart';

import '../data/quiz_repository.dart';
import '../domain/quiz.dart';

final quizClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

class QuizViewModel extends AsyncNotifier<QuizSession> {
  QuizViewModel(this.episode);
  final int episode;
  DateTime? _started;

  @override
  Future<QuizSession> build() async {
    if (episode != QuizDefinition.episode) return QuizSession();
    final result = await ref.watch(quizRepositoryProvider).latest();
    return switch (result) {
      Ok(:final value) => QuizSession(attempt: value),
      Err() => QuizSession(saveFailed: true),
    };
  }

  QuizSession get _value => state.requireValue;
  void start() {
    if (episode != QuizDefinition.episode) return;
    if (_value.saving) return;
    ref.read(audioViewModelProvider.notifier).pause();
    _started = ref.read(quizClockProvider)();
    state = AsyncData(
      QuizSession(stage: QuizStage.question, attempt: _value.attempt),
    );
  }

  void select(int option) {
    if (_value.stage != QuizStage.question ||
        _value.checked ||
        option < 0 ||
        option > 3) {
      return;
    }
    state = AsyncData(_value.copyWith(selected: option));
  }

  void check() {
    if (_value.stage != QuizStage.question ||
        _value.checked ||
        _value.selected == null) {
      return;
    }
    state = AsyncData(
      _value.copyWith(
        checked: true,
        answers: [..._value.answers, _value.selected!],
      ),
    );
  }

  Future<void> next() async {
    if (!_value.checked ||
        _value.saving ||
        _value.stage != QuizStage.question) {
      return;
    }
    if (!_value.isLast) {
      state = AsyncData(_value.copyWith(checked: false, clearSelection: true));
      return;
    }
    final now = ref.read(quizClockProvider)();
    final attempt = QuizAttempt(
      answers: _value.answers,
      finishedAt: now,
      elapsedSeconds: now.difference(_started!).inSeconds.clamp(0, 1 << 31),
    );
    state = AsyncData(
      _value.copyWith(stage: QuizStage.summary, attempt: attempt),
    );
    await retrySave();
  }

  Future<void> retrySave() async {
    if (_value.saving || _value.attempt == null) return;
    final repository = ref.read(quizRepositoryProvider);
    final attempt = _value.attempt!;
    state = AsyncData(_value.copyWith(saving: true, saveFailed: false));
    final result = await repository.save(attempt);
    if (!ref.mounted) return;
    state = AsyncData(
      _value.copyWith(saving: false, saveFailed: result is Err<void>),
    );
  }

  void review() => state = AsyncData(_value.copyWith(stage: QuizStage.review));
  void summary() =>
      state = AsyncData(_value.copyWith(stage: QuizStage.summary));
  void filter(QuizFilter filter) =>
      state = AsyncData(_value.copyWith(filter: filter));
  void abandon() => state = AsyncData(QuizSession(attempt: _value.attempt));
}

final quizViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<QuizViewModel, QuizSession, int>(QuizViewModel.new);
