import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:su_ky_mobile/core/error/result.dart';
import 'package:su_ky_mobile/features/quiz/data/quiz_repository.dart';
import 'package:su_ky_mobile/features/quiz/domain/quiz.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'empty history and completed results round-trip across repositories',
    () async {
      final repository = LocalQuizRepository();
      expect((await repository.latest() as Ok<QuizAttempt?>).value, isNull);
      final date = DateTime.utc(2026, 10, 30);
      final attempt = QuizAttempt(
        answers: [0, 1, 0, 0, 3, 1],
        finishedAt: date,
        elapsedSeconds: 225,
      );
      expect(await repository.save(attempt), isA<Ok<void>>());
      final loaded =
          (await LocalQuizRepository().latest() as Ok<QuizAttempt?>).value!;
      expect(loaded.answers, attempt.answers);
      expect(loaded.correctCount, 5);
      expect(loaded.percent, 83);
      expect(loaded.finishedAt, date);
      expect(loaded.elapsedSeconds, 225);
    },
  );
  test(
    'corrupt history is reported and can be replaced with a new result',
    () async {
      SharedPreferences.setMockInitialValues({
        'quiz.${QuizDefinition.id}.latest': '{"answers":[99],"seconds":-1}',
      });
      final repository = LocalQuizRepository();
      expect(await repository.latest(), isA<Err<QuizAttempt?>>());
      await repository.save(
        QuizAttempt(
          answers: [0, 1, 2, 0, 3, 1],
          finishedAt: DateTime.utc(2026),
          elapsedSeconds: 10,
        ),
      );
      expect(await repository.latest(), isA<Ok<QuizAttempt?>>());
    },
  );
}
