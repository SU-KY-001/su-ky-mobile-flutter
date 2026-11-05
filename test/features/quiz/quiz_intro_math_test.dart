import 'package:flutter_test/flutter_test.dart';
import 'package:su_ky_mobile/features/quiz/domain/quiz.dart';

Quiz _quiz({required int questions, required int passPercent}) => Quiz(
  id: 'q',
  episodeId: 'e',
  passScorePercent: passPercent,
  questions: [
    for (var i = 0; i < questions; i++)
      QuizQuestion(
        id: 'q$i',
        text: 't',
        sortOrder: i,
        options: const [QuizOption(id: 'o', label: 'A', text: 'x')],
      ),
  ],
);

void main() {
  group('Quiz.requiredCorrect', () {
    test('rounds up: 5 questions at 80% need 4', () {
      expect(_quiz(questions: 5, passPercent: 80).requiredCorrect, 4);
      expect(_quiz(questions: 3, passPercent: 50).requiredCorrect, 2);
    });

    test('boundaries: 0%, 100%, one question, no questions', () {
      expect(_quiz(questions: 5, passPercent: 0).requiredCorrect, 0);
      expect(_quiz(questions: 5, passPercent: 100).requiredCorrect, 5);
      expect(_quiz(questions: 1, passPercent: 80).requiredCorrect, 1);
      expect(_quiz(questions: 0, passPercent: 80).requiredCorrect, 0);
    });
  });

  group('Quiz.estimatedMinutes', () {
    test('never below one minute, rounds up', () {
      expect(_quiz(questions: 0, passPercent: 80).estimatedMinutes, 1);
      expect(_quiz(questions: 1, passPercent: 80).estimatedMinutes, 1);
      expect(_quiz(questions: 2, passPercent: 80).estimatedMinutes, 1);
      expect(_quiz(questions: 3, passPercent: 80).estimatedMinutes, 2);
      expect(_quiz(questions: 10, passPercent: 80).estimatedMinutes, 5);
    });
  });
}
