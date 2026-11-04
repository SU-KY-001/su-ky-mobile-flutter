import '../domain/quiz.dart';
import 'quiz_constants.dart';

/// Validates quiz JSON field by field. The raw map never leaves this file and
/// every failure names the field, never its value (answers stay private).
abstract final class QuizParser {
  static QuizCatalog catalog(Object? body) {
    final json = _object(body, 'quiz catalog');
    return QuizCatalog(
      items: _list(json, 'items').map(_card).toList(growable: false),
      total: _int(json, 'total', min: 0),
    );
  }

  static Quiz quiz(Object? body) {
    final json = _object(body, 'quiz');
    final questions = _list(json, 'questions').map(_question).toList();
    if (questions.isEmpty) {
      throw const FormatException('Field "questions" must not be empty');
    }
    questions.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return Quiz(
      id: _string(json, 'id'),
      episodeId: _string(json, 'episodeId'),
      passScorePercent: _int(
        json,
        'passScorePercent',
        min: QuizDefaults.minPercent,
        max: QuizDefaults.maxPercent,
      ),
      questions: List.unmodifiable(questions),
    );
  }

  static QuizResult result(Object? body) {
    final json = _object(body, 'quiz result');
    final answers = _list(json, 'answers').map(_answerResult).toList();
    return QuizResult(
      scorePercent: _int(
        json,
        'scorePercent',
        min: QuizDefaults.minPercent,
        max: QuizDefaults.maxPercent,
      ),
      isPassed: _bool(json, 'isPassed'),
      xpAwarded: _int(json, 'xpAwarded', min: 0),
      totalXp: _int(json, 'totalXp', min: 0),
      answers: List.unmodifiable(answers),
    );
  }

  static QuizCard _card(Object? item) {
    final json = _object(item, 'quiz card');
    return QuizCard(
      id: _string(json, 'id'),
      title: _string(json, 'title'),
      description: _optString(json, 'description'),
      episodeSlug: _string(json, 'episodeSlug'),
      episodeTitle: _string(json, 'episodeTitle'),
      seriesSlug: _string(json, 'seriesSlug'),
      seriesTitle: _string(json, 'seriesTitle'),
      topicId: _optString(json, 'topicId'),
      topicName: _optString(json, 'topicName'),
      posterUrl: _optString(json, 'posterUrl'),
      questionCount: _int(json, 'questionCount', min: 0),
      plays: _int(json, 'plays', min: 0),
      hasCompleted: _optBool(json, 'hasCompleted'),
    );
  }

  static QuizQuestion _question(Object? item) {
    final json = _object(item, 'question');
    final options = _list(json, 'options').map(_option).toList();
    if (options.length < QuizDefaults.minOptionsPerQuestion) {
      throw const FormatException(
        'Field "options" must have at least two entries',
      );
    }
    return QuizQuestion(
      id: _string(json, 'id'),
      text: _string(json, 'text'),
      sortOrder: _int(json, 'sortOrder', min: 0),
      options: List.unmodifiable(options),
    );
  }

  static QuizOption _option(Object? item) {
    final json = _object(item, 'option');
    return QuizOption(
      id: _string(json, 'id'),
      label: _string(json, 'label'),
      text: _string(json, 'text'),
    );
  }

  static QuizAnswerResult _answerResult(Object? item) {
    final json = _object(item, 'answer result');
    return QuizAnswerResult(
      questionId: _string(json, 'questionId'),
      selectedOptionId: _optString(json, 'selectedOptionId'),
      correctOptionId: _string(json, 'correctOptionId'),
      isCorrect: _bool(json, 'isCorrect'),
      explanation: _optString(json, 'explanation'),
    );
  }

  static Map<String, Object?> _object(Object? value, String what) {
    if (value is Map<String, Object?>) return value;
    throw FormatException('Expected $what to be an object');
  }

  static List<Object?> _list(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is List<Object?>) return value;
    throw FormatException('Field "$key" must be a list');
  }

  static String _string(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
    throw FormatException('Field "$key" must be a non-empty string');
  }

  static String? _optString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! String) {
      throw FormatException('Field "$key" must be a string');
    }
    return value.isEmpty ? null : value;
  }

  static int _int(
    Map<String, Object?> json,
    String key, {
    required int min,
    int? max,
  }) {
    final value = json[key];
    if (value is! int || value < min || (max != null && value > max)) {
      throw FormatException('Field "$key" must be an int in range');
    }
    return value;
  }

  static bool _bool(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is bool) return value;
    throw FormatException('Field "$key" must be a bool');
  }

  static bool? _optBool(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is bool) return value;
    throw FormatException('Field "$key" must be a bool');
  }
}
