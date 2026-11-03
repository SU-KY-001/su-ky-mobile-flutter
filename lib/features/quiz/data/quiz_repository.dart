import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/result.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/network/dio_factory.dart';
import '../../../shared/catalog/catalog_constants.dart';
import '../domain/quiz.dart';
import 'quiz_constants.dart';
import 'quiz_parser.dart';

abstract class QuizRepository {
  Future<Result<QuizCatalog>> catalog({
    String? topicId,
    int limit = QuizDefaults.catalogLimit,
  });

  Future<Result<Quiz>> episodeQuiz(String slug);

  /// [idempotencyKey] is generated once per attempt by the view model and kept
  /// across retries of the same submission.
  Future<Result<QuizResult>> submit({
    required String quizId,
    required String idempotencyKey,
    required List<QuizAnswer> answers,
  });
}

class ApiQuizRepository implements QuizRepository {
  ApiQuizRepository(this._dio);

  final Dio _dio;

  @override
  Future<Result<QuizCatalog>> catalog({
    String? topicId,
    int limit = QuizDefaults.catalogLimit,
  }) => _guard('Quiz catalog', () async {
    final res = await _dio.get<Object?>(
      QuizDefaults.quizzesPath,
      queryParameters: {
        'page': QuizDefaults.catalogPage,
        'limit': limit,
        'topicId': ?topicId,
      },
    );
    return QuizParser.catalog(res.data);
  });

  @override
  Future<Result<Quiz>> episodeQuiz(String slug) {
    if (!isValidSlug(slug)) {
      return Future.value(
        Err(
          ApiException(
            'Invalid episode slug',
            statusCode: QuizDefaults.notFoundStatus,
            errorCode: QuizDefaults.notFoundCode,
          ),
        ),
      );
    }
    return _guard('Episode quiz', () async {
      final res = await _dio.get<Object?>(
        '${QuizDefaults.episodesPath}/$slug/quiz',
      );
      return QuizParser.quiz(res.data);
    });
  }

  @override
  Future<Result<QuizResult>> submit({
    required String quizId,
    required String idempotencyKey,
    required List<QuizAnswer> answers,
  }) => _guard('Quiz submit', () async {
    final res = await _dio.post<Object?>(
      '${QuizDefaults.quizzesPath}/$quizId/attempts',
      options: Options(
        headers: {QuizDefaults.idempotencyHeader: idempotencyKey},
      ),
      data: {
        'answers': [
          for (final answer in answers)
            {'questionId': answer.questionId, 'optionId': answer.optionId},
        ],
      },
    );
    return QuizParser.result(res.data);
  });

  Future<Result<T>> _guard<T>(String what, Future<T> Function() call) async {
    try {
      return Ok(await call());
    } on DioException catch (e) {
      final error = e.error;
      return Err(error is AppException ? error : mapDioException(e));
    } on AppException catch (e) {
      return Err(e);
    } on FormatException catch (e, stack) {
      AppLogger.error('$what: unexpected payload', error: e, stackTrace: stack);
      return Err(UnknownException('$what: unexpected payload', cause: e));
    } catch (e, stack) {
      AppLogger.error('$what failed', error: e, stackTrace: stack);
      return Err(UnknownException('$what failed', cause: e));
    }
  }
}

final quizRepositoryProvider = Provider<QuizRepository>(
  (ref) => ApiQuizRepository(ref.watch(dioProvider)),
);
