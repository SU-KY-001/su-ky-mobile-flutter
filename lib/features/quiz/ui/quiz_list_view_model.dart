import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Selected topic filter of the quiz catalog. `null` means all topics.
final class QuizListState {
  const QuizListState({this.topicId});

  final String? topicId;

  QuizListState copyWith({String? topicId}) => QuizListState(topicId: topicId);
}

class QuizListViewModel extends Notifier<QuizListState> {
  @override
  QuizListState build() => const QuizListState();

  void select(String? topicId) {
    if (state.topicId == topicId) return;
    state = QuizListState(topicId: topicId);
  }
}

final quizListViewModelProvider =
    NotifierProvider.autoDispose<QuizListViewModel, QuizListState>(
      QuizListViewModel.new,
    );
