import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bumps whenever the user finishes a learning activity (an episode now, a
/// passed quiz later), so related data can refresh without polling. Lives in
/// `core` so `shared/audio` produces it and P7's missions consume it without
/// importing each other.
final learningActivityProvider = NotifierProvider<LearningActivity, int>(
  LearningActivity.new,
);

class LearningActivity extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}
