import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';

import '../domain/quiz.dart';
import 'quiz_chip.dart';

const _chipGap = 8.0;

/// Topic filter options derived from the unfiltered catalog (no `/api/topics`).
final class QuizTopic {
  const QuizTopic({required this.id, required this.name});

  final String id;
  final String name;
}

/// Unique topics in first-seen order; cards without a topic are skipped.
List<QuizTopic> quizTopicsOf(QuizCatalog catalog) {
  final seen = <String>{};
  final topics = <QuizTopic>[];
  for (final card in catalog.items) {
    final id = card.topicId;
    final name = card.topicName;
    if (id == null || name == null || !seen.add(id)) continue;
    topics.add(QuizTopic(id: id, name: name));
  }
  return topics;
}

class QuizTopicChips extends StatelessWidget {
  const QuizTopicChips({
    super.key,
    required this.topics,
    required this.selectedTopicId,
    required this.onSelected,
  });

  final List<QuizTopic> topics;
  final String? selectedTopicId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          QuizChoiceChip(
            label: l.quizAllTopics,
            selected: selectedTopicId == null,
            onSelected: () => onSelected(null),
          ),
          for (final topic in topics) ...[
            const SizedBox(width: _chipGap),
            QuizChoiceChip(
              label: topic.name,
              selected: selectedTopicId == topic.id,
              onSelected: () => onSelected(topic.id),
            ),
          ],
        ],
      ),
    );
  }
}
