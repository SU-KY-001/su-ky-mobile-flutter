import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/catalog_states.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

import '../data/quiz_providers.dart';
import '../domain/quiz.dart';
import 'quiz_card.dart';
import 'quiz_list_view_model.dart';
import 'quiz_topic_chips.dart';

const _eyebrowGap = 8.0;
const _titleGap = 16.0;
const _sectionGap = 24.0;
const _cardsGap = 12.0;
const _eyebrowLetterSpacing = 1.2;

class QuizListScreen extends ConsumerWidget {
  const QuizListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(quizListViewModelProvider);
    final viewModel = ref.read(quizListViewModelProvider.notifier);
    final catalog = ref.watch(quizCatalogProvider(state.topicId));
    final all = ref.watch(quizCatalogProvider(null));
    final allCatalog = all.value;
    final topics = allCatalog == null
        ? const <QuizTopic>[]
        : quizTopicsOf(allCatalog);

    return AppPage(
      child: ListView(
        padding: const EdgeInsets.all(AppDesign.pagePadding),
        children: [
          Text(
            l.quizListEyebrow,
            style: context.text.labelMedium?.copyWith(
              color: AppDesign.red,
              fontWeight: FontWeight.w700,
              letterSpacing: _eyebrowLetterSpacing,
            ),
          ),
          const SizedBox(height: _eyebrowGap),
          Text(
            l.quizListTitle,
            style: context.text.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (topics.isNotEmpty) ...[
            const SizedBox(height: _titleGap),
            QuizTopicChips(
              topics: topics,
              selectedTopicId: state.topicId,
              onSelected: viewModel.select,
            ),
          ],
          const SizedBox(height: _sectionGap),
          catalog.when(
            loading: () => const CatalogLoading(),
            error: (error, _) => CatalogError(
              error: error,
              onRetry: () => ref.invalidate(quizCatalogProvider(state.topicId)),
            ),
            data: (value) => value.isEmpty
                ? CatalogEmpty(
                    title: l.quizListEmptyTitle,
                    message: l.quizListEmptyMessage,
                  )
                : _QuizCards(cards: value.items),
          ),
        ],
      ),
    );
  }
}

class _QuizCards extends StatelessWidget {
  const _QuizCards({required this.cards});

  final List<QuizCard> cards;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final card in cards) ...[
        QuizCatalogCard(card: card),
        const SizedBox(height: _cardsGap),
      ],
    ],
  );
}
