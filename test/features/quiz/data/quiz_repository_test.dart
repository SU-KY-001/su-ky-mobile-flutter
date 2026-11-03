import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:su_ky_mobile/core/error/app_exception.dart';
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

  group('stored JSON that violates the contract is rejected', () {
    const key = 'quiz.${QuizDefinition.id}.latest';
    const valid = '"answers":[0,1,2,0,3,1],"seconds":10';
    final cases = {
      'not an object': '[1,2]',
      'not JSON at all': 'oops',
      'missing answers': '{"seconds":10,"finishedAt":"2026-10-30T00:00:00Z"}',
      'too few answers':
          '{"answers":[0],"seconds":10,"finishedAt":"2026-10-30T00:00:00Z"}',
      'answer above option range': '{"answers":[0,1,2,0,3,4],"seconds":10,"finishedAt":"2026-10-30T00:00:00Z"}',
      'fractional answer': '{"answers":[0,1,2,0,3,1.5],"seconds":10,"finishedAt":"2026-10-30T00:00:00Z"}',
      'negative seconds': '{"answers":[0,1,2,0,3,1],"seconds":-1,"finishedAt":"2026-10-30T00:00:00Z"}',
      'absurd duration': '{"answers":[0,1,2,0,3,1],"seconds":999999,"finishedAt":"2026-10-30T00:00:00Z"}',
      'missing date': '{$valid}',
      'date not a string': '{$valid,"finishedAt":20261030}',
      'date not ISO 8601': '{$valid,"finishedAt":"30/10/2026"}',
    };
    for (final entry in cases.entries) {
      test(entry.key, () async {
        SharedPreferences.setMockInitialValues({key: entry.value});
        final result = await LocalQuizRepository().latest();
        expect(result, isA<Err<QuizAttempt?>>());
        expect((result as Err<QuizAttempt?>).error, isA<StorageException>());
      });
    }
    test('well-formed JSON is still accepted', () async {
      SharedPreferences.setMockInitialValues({
        key: '{$valid,"finishedAt":"2026-10-30T00:00:00.000Z"}',
      });
      final result = await LocalQuizRepository().latest();
      expect((result as Ok<QuizAttempt?>).value!.elapsedSeconds, 10);
    });
  });
}
