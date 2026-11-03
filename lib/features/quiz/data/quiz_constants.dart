/// Quiz API paths and tuning values.
abstract final class QuizDefaults {
  static const quizzesPath = '/api/quizzes';
  static const episodesPath = '/api/episodes';
  static const idempotencyHeader = 'Idempotency-Key';

  /// The API caps `limit` at 50. The app has no pagination (RN parity).
  static const catalogLimit = 50;
  static const catalogPage = 1;

  /// Matches the RN query client `staleTime`.
  static const catalogCache = Duration(minutes: 5);

  /// A question needs at least two options to be answerable.
  static const minOptionsPerQuestion = 2;
  static const minPercent = 0;
  static const maxPercent = 100;

  static const notFoundStatus = 404;
  static const notFoundCode = 'NOT_FOUND';
}
