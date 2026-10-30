enum QuizStage { introduction, question, summary, review }

enum QuizFilter { all, incorrect, correct }

class QuizQuestion {
  const QuizQuestion(this.id, this.correctOption);
  final String id;
  final int correctOption;
}

abstract final class QuizDefinition {
  static const episode = 1;
  static const id = 'bach-dang-938-episode-2-v1';
  static const estimatedMinutes = 5;
  static const questions = [
    QuizQuestion('stakes', 0),
    QuizQuestion('tide', 1),
    QuizQuestion('commander', 2),
    QuizQuestion('timing', 0),
    QuizQuestion('meaning', 3),
    QuizQuestion('preparation', 1),
  ];
}

class QuizAttempt {
  QuizAttempt({
    required List<int> answers,
    required this.finishedAt,
    required this.elapsedSeconds,
  }) : answers = List.unmodifiable(answers);
  final List<int> answers;
  final DateTime finishedAt;
  final int elapsedSeconds;
  int get correctCount => [
    for (var i = 0; i < answers.length; i++)
      if (answers[i] == QuizDefinition.questions[i].correctOption) i,
  ].length;
  int get percent =>
      (correctCount / QuizDefinition.questions.length * 100).round();
}

class QuizSession {
  QuizSession({
    this.stage = QuizStage.introduction,
    List<int> answers = const [],
    this.selected,
    this.checked = false,
    this.attempt,
    this.filter = QuizFilter.all,
    this.saving = false,
    this.saveFailed = false,
  }) : answers = List.unmodifiable(answers);
  final QuizStage stage;
  final List<int> answers;
  final int? selected;
  final bool checked;
  final QuizAttempt? attempt;
  final QuizFilter filter;
  final bool saving;
  final bool saveFailed;
  int get questionIndex => checked ? answers.length - 1 : answers.length;
  QuizQuestion get question => QuizDefinition.questions[questionIndex];
  bool get isCorrect => selected == question.correctOption;
  bool get isLast => answers.length == QuizDefinition.questions.length;

  QuizSession copyWith({
    QuizStage? stage,
    List<int>? answers,
    int? selected,
    bool clearSelection = false,
    bool? checked,
    QuizAttempt? attempt,
    QuizFilter? filter,
    bool? saving,
    bool? saveFailed,
  }) => QuizSession(
    stage: stage ?? this.stage,
    answers: answers ?? this.answers,
    selected: clearSelection ? null : selected ?? this.selected,
    checked: checked ?? this.checked,
    attempt: attempt ?? this.attempt,
    filter: filter ?? this.filter,
    saving: saving ?? this.saving,
    saveFailed: saveFailed ?? this.saveFailed,
  );
}
