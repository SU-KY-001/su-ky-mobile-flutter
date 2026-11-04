import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:su_ky_mobile/core/error/result.dart';
import 'package:su_ky_mobile/features/quiz/data/quiz_providers.dart';
import 'package:su_ky_mobile/features/quiz/data/quiz_repository.dart';
import 'package:su_ky_mobile/features/quiz/domain/quiz.dart';
import 'package:su_ky_mobile/features/quiz/ui/quiz_intro_view.dart';
import 'package:su_ky_mobile/features/quiz/ui/quiz_session.dart';
import 'package:su_ky_mobile/features/quiz/ui/quiz_view_model.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/data/catalog_providers.dart';
import 'package:su_ky_mobile/shared/catalog/domain/episode_detail.dart';
import 'package:su_ky_mobile/shared/widgets/cover_art.dart';

const _slug = 'ep-1';
const _poster = 'https://cdn.example.com/quiz-poster.jpg';
const _quizTitle = 'Văn hoá Đông Sơn';
const _episodeTitle = 'Văn hóa Đồng Sơn';

const _quiz = Quiz(
  id: 'quiz-1',
  episodeId: 'ep-1',
  passScorePercent: 80,
  questions: [
    QuizQuestion(
      id: 'q1',
      text: 'Q1',
      sortOrder: 1,
      options: [QuizOption(id: 'q1-a', label: 'A', text: 'Một')],
    ),
  ],
);

const _episode = EpisodeDetail(
  id: 'e',
  slug: _slug,
  title: _episodeTitle,
  seriesSlug: 's',
  seriesTitle: 'S',
  seriesCoverUrl: 'https://cdn.example.com/series-cover.jpg',
  hasQuiz: true,
  narrations: [],
);

const _card = QuizCard(
  id: 'quiz-1',
  title: _quizTitle,
  episodeSlug: _slug,
  episodeTitle: _episodeTitle,
  seriesSlug: 's',
  seriesTitle: 'S',
  questionCount: 1,
  plays: 0,
  posterUrl: _poster,
);

class _Repo implements QuizRepository {
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
  }) => throw UnimplementedError();
}

Future<void> _pump(WidgetTester tester, List<QuizCard> cards) async {
  final container = ProviderContainer(
    overrides: [
      quizRepositoryProvider.overrideWithValue(_Repo()),
      quizCatalogProvider.overrideWith(
        (ref, topicId) async => QuizCatalog(items: cards, total: cards.length),
      ),
      episodeDetailProvider.overrideWith((ref, slug) async => _episode),
    ],
  );
  addTearDown(container.dispose);
  final viewModel = container
      .listen(quizViewModelProvider(_slug).notifier, (_, _) {})
      .read();
  container.listen(quizCatalogProvider(null), (_, _) {});
  container.listen(episodeDetailProvider(_slug), (_, _) {});
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: QuizIntroView(
            session: QuizSession(quiz: _quiz),
            viewModel: viewModel,
            slug: _slug,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('shows the quiz title and poster from its catalog card', (
    tester,
  ) async {
    await _pump(tester, [_card]);
    expect(find.text(_quizTitle), findsOneWidget);
    expect(find.text(_episodeTitle), findsNothing);
    expect(tester.widget<CoverArt>(find.byType(CoverArt)).url, _poster);
  });

  testWidgets('without a card falls back to the episode title, no poster', (
    tester,
  ) async {
    await _pump(tester, const []);
    expect(find.text(_episodeTitle), findsOneWidget);
    expect(tester.widget<CoverArt>(find.byType(CoverArt)).url, isNull);
  });
}
