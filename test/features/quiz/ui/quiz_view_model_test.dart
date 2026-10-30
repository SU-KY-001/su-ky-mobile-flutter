import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:su_ky_mobile/core/error/app_exception.dart';
import 'package:su_ky_mobile/core/error/result.dart';
import 'package:su_ky_mobile/features/quiz/data/quiz_repository.dart';
import 'package:su_ky_mobile/features/quiz/domain/quiz.dart';
import 'package:su_ky_mobile/features/quiz/ui/quiz_view_model.dart';
import 'package:su_ky_mobile/shared/audio/audio_view_model.dart';

class FakeQuizRepository implements QuizRepository {
  QuizAttempt? stored;
  bool fail = false;
  int saves = 0;
  @override
  Future<Result<QuizAttempt?>> latest() async => Ok(stored);
  @override
  Future<Result<void>> save(QuizAttempt attempt) async {
    saves++;
    if (fail) return const Err(StorageException('test failure'));
    stored = attempt;
    return const Ok(null);
  }
}

void main() {
  late ProviderContainer container;
  late FakeQuizRepository repository;
  late DateTime now;
  final provider = quizViewModelProvider(QuizDefinition.episode);
  setUp(() async {
    repository = FakeQuizRepository();
    now = DateTime.utc(2026, 10, 30, 10);
    container = ProviderContainer(
      overrides: [
        quizRepositoryProvider.overrideWithValue(repository),
        quizClockProvider.overrideWithValue(() => now),
      ],
    );
    container.listen(provider, (_, next) {});
    await container.read(provider.future);
  });
  tearDown(() => container.dispose());

  test(
    'selection is required and a checked answer cannot change or score twice',
    () {
      final vm = container.read(provider.notifier);
      vm.start();
      vm.check();
      expect(container.read(provider).requireValue.answers, isEmpty);
      vm.select(-1);
      expect(container.read(provider).requireValue.selected, isNull);
      vm.select(0);
      vm.check();
      vm.select(1);
      vm.check();
      final state = container.read(provider).requireValue;
      expect(state.answers, [0]);
      expect(state.selected, 0);
      expect(state.isCorrect, isTrue);
    },
  );

  Future<void> complete({bool wrong = false}) async {
    final vm = container.read(provider.notifier);
    vm.start();
    now = now.add(const Duration(seconds: 225));
    for (final question in QuizDefinition.questions) {
      vm.select(
        wrong ? (question.correctOption + 1) % 4 : question.correctOption,
      );
      vm.check();
      await vm.next();
    }
  }

  test(
    'completion computes actual score and elapsed time and persists once',
    () async {
      await complete();
      final state = container.read(provider).requireValue;
      expect(state.stage, QuizStage.summary);
      expect(state.attempt!.correctCount, QuizDefinition.questions.length);
      expect(state.attempt!.percent, 100);
      expect(state.attempt!.elapsedSeconds, 225);
      expect(repository.saves, 1);
      await container.read(provider.notifier).next();
      expect(repository.saves, 1);
      expect(repository.stored, state.attempt);
    },
  );

  test(
    'all wrong answers produce zero and review preserves the attempt',
    () async {
      await complete(wrong: true);
      final vm = container.read(provider.notifier);
      vm.review();
      vm.filter(QuizFilter.incorrect);
      expect(container.read(provider).requireValue.attempt!.percent, 0);
      expect(
        container.read(provider).requireValue.filter,
        QuizFilter.incorrect,
      );
      vm.summary();
      expect(container.read(provider).requireValue.stage, QuizStage.summary);
    },
  );

  test('a failed write keeps results available and can be retried', () async {
    repository.fail = true;
    await complete();
    expect(container.read(provider).requireValue.saveFailed, isTrue);
    expect(container.read(provider).requireValue.attempt!.percent, 100);
    repository.fail = false;
    await container.read(provider.notifier).retrySave();
    expect(container.read(provider).requireValue.saveFailed, isFalse);
    expect(repository.stored, isNotNull);
  });

  test(
    'restart resets answers and abandon preserves only the completed result',
    () async {
      await complete();
      final attempt = repository.stored;
      final vm = container.read(provider.notifier);
      vm.start();
      expect(container.read(provider).requireValue.answers, isEmpty);
      expect(container.read(provider).requireValue.selected, isNull);
      vm.select(2);
      vm.abandon();
      expect(
        container.read(provider).requireValue.stage,
        QuizStage.introduction,
      );
      expect(container.read(provider).requireValue.attempt, attempt);
      expect(repository.saves, 1);
    },
  );

  test('starting the quiz pauses the shared player', () {
    container.read(audioViewModelProvider.notifier).playEpisode(1);
    container.read(provider.notifier).start();
    expect(container.read(audioViewModelProvider).playing, isFalse);
  });
}
