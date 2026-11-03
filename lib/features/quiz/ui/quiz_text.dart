import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';

/// Localized copy of one question: prompt, options and explanation.
typedef QuizText = (String question, List<String> options, String explanation);

const _optionSeparator = ' | ';

QuizText quizText(AppLocalizations l, String id) {
  final (question, options, explanation) = switch (id) {
    'stakes' => (l.quizQuestion1, l.quizOptions1, l.quizExplanation1),
    'tide' => (l.quizQuestion2, l.quizOptions2, l.quizExplanation2),
    'commander' => (l.quizQuestion3, l.quizOptions3, l.quizExplanation3),
    'timing' => (l.quizQuestion4, l.quizOptions4, l.quizExplanation4),
    'meaning' => (l.quizQuestion5, l.quizOptions5, l.quizExplanation5),
    _ => (l.quizQuestion6, l.quizOptions6, l.quizExplanation6),
  };
  return (question, options.split(_optionSeparator), explanation);
}
