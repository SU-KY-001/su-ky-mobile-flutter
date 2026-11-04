import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:su_ky_mobile/core/activity/learning_activity.dart';
import 'package:su_ky_mobile/core/di/app_retry.dart';
import 'package:su_ky_mobile/core/error/app_exception.dart';
import 'package:su_ky_mobile/core/error/result.dart';
import 'package:su_ky_mobile/features/quiz/data/idempotency_key.dart';
import 'package:su_ky_mobile/features/quiz/data/quiz_providers.dart';
import 'package:su_ky_mobile/features/quiz/data/quiz_repository.dart';
import 'package:su_ky_mobile/features/quiz/domain/quiz.dart';
import 'package:su_ky_mobile/features/quiz/domain/quiz_stage.dart';
import 'package:su_ky_mobile/features/quiz/ui/quiz_session.dart';
import 'package:su_ky_mobile/features/quiz/ui/quiz_view_model.dart';
import 'package:su_ky_mobile/shared/audio/playback_controller.dart';
import 'package:su_ky_mobile/shared/audio/playback_state.dart';

import '../../support/stub_http.dart';

Map<String, Object?> _questionJson(String id, int order) => {
  'id': id,
  'text': 'Q $id',
  'sortOrder': order,
  'options': [
    {'id': '$id-a', 'label': 'A', 'text': 'Một'},
    {'id': '$id-b', 'label': 'B', 'text': 'Hai'},
  ],
};

Map<String, Object?> _quizJson({List<Object?>? questions}) => {
  'id': 'quiz-1',
  'episodeId': 'ep-1',
  'passScorePercent': 70,
  'questions': questions ?? [_questionJson('q2', 2), _questionJson('q1', 1)],
};

Map<String, Object?> _resultJson({bool passed = true}) => {
  'scorePercent': passed ? 100 : 40,
  'isPassed': passed,
  'xpAwarded': passed ? 20 : 0,
  'totalXp': 140,
  'answers': [
    {
      'questionId': 'q1',
      'selectedOptionId': 'q1-a',
      'correctOptionId': 'q1-a',
      'isCorrect': true,
      'explanation': 'Vì sao',
    },
    {
      'questionId': 'q2',
      'selectedOptionId': null,
      'correctOptionId': 'q2-b',
      'isCorrect': false,
      'explanation': null,
    },
  ],
};

Map<String, Object?> _cardJson({Object? done = false}) => {
  'id': 'quiz-1',
  'title': 'Quiz',
  'description': null,
  'episodeSlug': 'ep-1',
  'episodeTitle': 'Ep',
  'seriesSlug': 's',
  'seriesTitle': 'S',
  'topicId': null,
  'topicName': null,
  'posterUrl': null,
  'questionCount': 2,
  'plays': 3,
  'hasCompleted': done,
};

ApiQuizRepository _repo(StubHandler h) => ApiQuizRepository(stubDio(h).$1);

class _NoopPlayback extends PlaybackController {
  int pauses = 0;
  @override
  PlaybackState build() => const PlaybackState();
  @override
  Future<void> pause() async => pauses++;
}

const _quiz = Quiz(
  id: 'quiz-1',
  episodeId: 'ep-1',
  passScorePercent: 70,
  questions: [
    QuizQuestion(
      id: 'q1',
      text: 'Q1',
      sortOrder: 1,
      options: [
        QuizOption(id: 'q1-a', label: 'A', text: 'Một'),
        QuizOption(id: 'q1-b', label: 'B', text: 'Hai'),
      ],
    ),
    QuizQuestion(
      id: 'q2',
      text: 'Q2',
      sortOrder: 2,
      options: [
        QuizOption(id: 'q2-a', label: 'A', text: 'Một'),
        QuizOption(id: 'q2-b', label: 'B', text: 'Hai'),
      ],
    ),
  ],
);

QuizResult _result({bool passed = true}) => QuizResult(
  scorePercent: passed ? 100 : 40,
  isPassed: passed,
  xpAwarded: passed ? 20 : 0,
  totalXp: 140,
  answers: const [
    QuizAnswerResult(
      questionId: 'q1',
      selectedOptionId: 'q1-a',
      correctOptionId: 'q1-a',
      isCorrect: true,
    ),
    QuizAnswerResult(
      questionId: 'q2',
      selectedOptionId: 'q2-a',
      correctOptionId: 'q2-b',
      isCorrect: false,
    ),
  ],
);

class _FakeRepo implements QuizRepository {
  final keys = <String>[];
  final submissions = <List<QuizAnswer>>[];
  Result<QuizResult> Function() onSubmit = () => Ok(_result());

  @override
  Future<Result<QuizCatalog>> catalog({
    String? topicId,
    int limit = 50,
  }) async => const Ok(QuizCatalog(items: [], total: 0));

  @override
  Future<Result<Quiz>> episodeQuiz(String slug) async => const Ok(_quiz);

  @override
  Future<Result<QuizResult>> submit({
    required String quizId,
    required String idempotencyKey,
    required List<QuizAnswer> answers,
  }) async {
    keys.add(idempotencyKey);
    submissions.add(answers);
    return onSubmit();
  }
}

class _SlowRepo extends _FakeRepo {
  final completer = Completer<Result<QuizResult>>();

  @override
  Future<Result<QuizResult>> submit({
    required String quizId,
    required String idempotencyKey,
    required List<QuizAnswer> answers,
  }) {
    keys.add(idempotencyKey);
    return completer.future;
  }
}

Future<(ProviderContainer, _FakeRepo, _NoopPlayback)> _setup() async {
  final repo = _FakeRepo();
  final playback = _NoopPlayback();
  final c = ProviderContainer(
    overrides: [
      quizRepositoryProvider.overrideWithValue(repo),
      playbackControllerProvider.overrideWith(() => playback),
    ],
  );
  addTearDown(c.dispose);
  c.listen(quizViewModelProvider('ep-1'), (_, _) {});
  await c.read(quizViewModelProvider('ep-1').future);
  return (c, repo, playback);
}

QuizViewModel _vm(ProviderContainer c) =>
    c.read(quizViewModelProvider('ep-1').notifier);

QuizSession _s(ProviderContainer c) =>
    c.read(quizViewModelProvider('ep-1')).requireValue;

Future<void> _answerAll(ProviderContainer c) async {
  _vm(c).start();
  _vm(c).select('q1-a');
  await _vm(c).next();
  _vm(c).select('q2-a');
}

void main() {
  group('idempotency key', () {
    test('is a v4 UUID and unique', () {
      final pattern = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );
      final keys = {for (var i = 0; i < 50; i++) newIdempotencyKey()};
      expect(keys.length, 50);
      expect(keys.every(pattern.hasMatch), isTrue);
    });
  });

  group('ApiQuizRepository', () {
    test('catalog parses cards; hasCompleted is null for guests', () async {
      final (dio, adapter) = stubDio(
        (_) => StubReply(200, {
          'items': [_cardJson(done: null), _cardJson(done: true)],
          'total': 2,
        }),
      );
      final r = await ApiQuizRepository(dio).catalog(topicId: 't1');
      final catalog = (r as Ok<QuizCatalog>).value;
      expect(catalog.items.map((c) => c.hasCompleted), [null, true]);
      expect(adapter.requests.single.queryParameters, {
        'page': 1,
        'limit': 50,
        'topicId': 't1',
      });
    });

    test(
      'a quiz is sorted by sortOrder; no questions or one option is rejected',
      () async {
        final ok = await _repo((_) => StubReply(200, _quizJson()))
            .episodeQuiz('ep-1');
        expect((ok as Ok<Quiz>).value.questions.map((q) => q.id), ['q1', 'q2']);

        final empty = await _repo(
          (_) => StubReply(200, _quizJson(questions: <Object?>[])),
        ).episodeQuiz('ep-1');
        expect(empty, isA<Err<Quiz>>());

        final thin = _questionJson('q1', 1)
          ..['options'] = [
            {'id': 'a', 'label': 'A', 'text': 'x'},
          ];
        final one = await _repo(
          (_) => StubReply(200, _quizJson(questions: [thin])),
        ).episodeQuiz('ep-1');
        expect(one, isA<Err<Quiz>>());
      },
    );

    test('a guest gets 401 AUTH_REQUIRED as an ApiException', () async {
      final r = await _repo(
        (_) => const StubReply(401, {
          'error_code': 'AUTH_REQUIRED',
          'message': 'x',
        }),
      ).episodeQuiz('ep-1');
      final e = (r as Err<Quiz>).error as ApiException;
      expect(e.statusCode, 401);
      expect(e.errorCode, 'AUTH_REQUIRED');
    });

    test('an invalid slug is rejected locally', () async {
      final (dio, adapter) = stubDio((_) => const StubReply(200, {}));
      expect(
        await ApiQuizRepository(dio).episodeQuiz('Bad/Slug'),
        isA<Err<Quiz>>(),
      );
      expect(adapter.requests, isEmpty);
    });

    test(
      'submit sends the key header and answers, parses a null selection',
      () async {
        final (dio, adapter) = stubDio((_) => StubReply(200, _resultJson()));
        final r = await ApiQuizRepository(dio).submit(
          quizId: 'quiz-1',
          idempotencyKey: 'key-1',
          answers: const [QuizAnswer(questionId: 'q1', optionId: 'q1-a')],
        );
        final result = (r as Ok<QuizResult>).value;
        expect(result.answers.last.selectedOptionId, isNull);
        expect(result.totalXp, 140);
        final req = adapter.requests.single;
        expect(req.headers['Idempotency-Key'], 'key-1');
        expect(req.path, '/api/quizzes/quiz-1/attempts');
        expect(req.data, {
          'answers': [
            {'questionId': 'q1', 'optionId': 'q1-a'},
          ],
        });
      },
    );

    test('score above 100 or negative XP is a malformed result', () async {
      for (final patch in [
        {'scorePercent': 101},
        {'xpAwarded': -1},
        {'isPassed': 'yes'},
      ]) {
        final r = await _repo(
          (_) => StubReply(200, {..._resultJson(), ...patch}),
        ).submit(quizId: 'q', idempotencyKey: 'k', answers: const []);
        expect(r, isA<Err<QuizResult>>(), reason: '$patch');
      }
    });

    test('a reused key with different content is a 422 ApiException', () async {
      final r = await _repo(
        (_) => const StubReply(422, {
          'error_code': 'IDEMPOTENCY_KEY_REUSED',
          'message': 'x',
        }),
      ).submit(quizId: 'q', idempotencyKey: 'k', answers: const []);
      expect(
        ((r as Err<QuizResult>).error as ApiException).errorCode,
        'IDEMPOTENCY_KEY_REUSED',
      );
    });
  });

  group('QuizViewModel', () {
    test(
      'starts in the introduction; start pauses audio and sets a key',
      () async {
        final (c, _, playback) = await _setup();
        expect(_s(c).stage, QuizStage.introduction);
        _vm(c).start();
        expect(_s(c).stage, QuizStage.question);
        expect(_s(c).attemptKey, isNotNull);
        expect(playback.pauses, 1);
      },
    );

    test('Next needs an answer; unknown options are ignored', () async {
      final (c, _, _) = await _setup();
      _vm(c).start();
      await _vm(c).next();
      expect(_s(c).index, 0);
      _vm(c).select('not-an-option');
      expect(_s(c).answers, isEmpty);
      _vm(c).select('q1-b');
      await _vm(c).next();
      expect(_s(c).index, 1);
    });

    test('passing submits once, shows the summary, bumps activity', () async {
      final (c, repo, _) = await _setup();
      final before = c.read(learningActivityProvider);
      await _answerAll(c);
      await _vm(c).next();
      expect(_s(c).stage, QuizStage.summary);
      expect(_s(c).correctCount, 1);
      expect(repo.submissions.single.map((a) => a.questionId), ['q1', 'q2']);
      expect(c.read(learningActivityProvider), before + 1);
    });

    test('failing does not bump activity', () async {
      final (c, repo, _) = await _setup();
      repo.onSubmit = () => Ok(_result(passed: false));
      final before = c.read(learningActivityProvider);
      await _answerAll(c);
      await _vm(c).next();
      expect(_s(c).stage, QuizStage.summary);
      expect(c.read(learningActivityProvider), before);
    });

    test('a failed submit keeps the key; retry reuses it', () async {
      final (c, repo, _) = await _setup();
      repo.onSubmit = () => const Err(NetworkException('down'));
      await _answerAll(c);
      await _vm(c).next();
      expect(_s(c).submitError, isA<NetworkException>());
      expect(_s(c).stage, QuizStage.question);
      expect(_s(c).submitting, isFalse);

      repo.onSubmit = () => Ok(_result());
      await _vm(c).submit();
      expect(repo.keys.length, 2);
      expect(repo.keys.first, repo.keys.last);
      expect(_s(c).stage, QuizStage.summary);
    });

    test('retake starts clean with a new key', () async {
      final (c, repo, _) = await _setup();
      await _answerAll(c);
      await _vm(c).next();
      final firstKey = repo.keys.single;
      _vm(c).retake();
      expect(_s(c).stage, QuizStage.question);
      expect(_s(c).answers, isEmpty);
      expect(_s(c).result, isNull);
      expect(_s(c).attemptKey, isNot(firstKey));
    });

    test('review and summary need a result; filter is kept', () async {
      final (c, _, _) = await _setup();
      _vm(c).review();
      expect(_s(c).stage, QuizStage.introduction);
      await _answerAll(c);
      await _vm(c).next();
      _vm(c).review();
      expect(_s(c).stage, QuizStage.review);
      _vm(c).filter(QuizFilter.incorrect);
      expect(_s(c).filter, QuizFilter.incorrect);
      expect(_s(c).reviewEntries.length, 2);
      _vm(c).summary();
      expect(_s(c).stage, QuizStage.summary);
    });

    test('a double tap on Start starts once', () async {
      final (c, _, playback) = await _setup();
      _vm(c).start();
      _vm(c).start();
      expect(playback.pauses, 1);
      expect(_s(c).stage, QuizStage.question);
      expect(_s(c).index, 0);
    });

    test('abandoning during submit ignores the late result', () async {
      final repo = _SlowRepo();
      final c = ProviderContainer(
        overrides: [
          quizRepositoryProvider.overrideWithValue(repo),
          playbackControllerProvider.overrideWith(() => _NoopPlayback()),
        ],
      );
      addTearDown(c.dispose);
      c.listen(quizViewModelProvider('ep-1'), (_, _) {});
      await c.read(quizViewModelProvider('ep-1').future);
      final vm = c.read(quizViewModelProvider('ep-1').notifier);

      vm.start();
      vm.select('q1-a');
      await vm.next();
      vm.select('q2-a');
      final pending = vm.next();
      vm.abandon();
      repo.completer.complete(Ok(_result()));
      await pending;

      expect(_s(c).stage, QuizStage.introduction);
      expect(_s(c).result, isNull);
      expect(_s(c).submitting, isFalse);
    });

    test('a double tap on the last question submits once', () async {
      final (c, repo, _) = await _setup();
      await _answerAll(c);
      final first = _vm(c).next();
      await _vm(c).next();
      await first;
      expect(repo.keys.length, 1);
    });
  });

  group('quizCatalogProvider', () {
    test('an error surfaces as AsyncError with the typed exception', () async {
      final repo = _FakeRepoCatalog();
      final c = ProviderContainer(
        retry: appRetry,
        overrides: [quizRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);
      c.listen(quizCatalogProvider(null), (_, _) {});
      await expectLater(
        c.read(quizCatalogProvider(null).future),
        throwsA(isA<ApiException>()),
      );
    });
  });
}

class _FakeRepoCatalog extends _FakeRepo {
  @override
  Future<Result<QuizCatalog>> catalog({
    String? topicId,
    int limit = 50,
  }) async => const Err(ApiException('x', statusCode: 404));
}
