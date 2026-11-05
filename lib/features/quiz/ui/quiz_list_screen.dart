import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/catalog_states.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

import '../data/quiz_providers.dart';
import '../domain/quiz.dart';
import 'quiz_list_row.dart';
import 'quiz_list_view_model.dart';
import 'quiz_topic_chips.dart';

const _chipsPadding = EdgeInsets.fromLTRB(
  AppDesign.pagePadding,
  0,
  AppDesign.pagePadding,
  8,
);
const _titleSize = 20.0;

class QuizListScreen extends ConsumerWidget {
  const QuizListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(quizListViewModelProvider);
    final viewModel = ref.read(quizListViewModelProvider.notifier);
    final catalog = ref.watch(quizCatalogProvider(state.topicId));
    final allCatalog = ref.watch(quizCatalogProvider(null)).value;
    final topics = allCatalog == null
        ? const <QuizTopic>[]
        : quizTopicsOf(allCatalog);

    return AppPage(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          l.quizListTitle,
          style: const TextStyle(
            fontSize: _titleSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: ListView(
        children: [
          if (topics.isNotEmpty)
            Padding(
              padding: _chipsPadding,
              child: QuizTopicChips(
                topics: topics,
                selectedTopicId: state.topicId,
                onSelected: viewModel.select,
              ),
            ),
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
                : _QuizRows(cards: value.items),
          ),
        ],
      ),
    );
  }
}

class _QuizRows extends StatelessWidget {
  const _QuizRows({required this.cards});

  final List<QuizCard> cards;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < cards.length; i++) ...[
        if (i > 0) const Divider(height: 1),
        QuizListRow(card: cards[i]),
      ],
    ],
  );
}
