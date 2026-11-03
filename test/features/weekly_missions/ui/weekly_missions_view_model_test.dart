import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:su_ky_mobile/features/weekly_missions/domain/mission.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_missions_view_model.dart';

void main() {
  const pending = Mission(
    kind: MissionKind.journey,
    points: 70,
    current: 1,
    target: 3,
  );
  const done = Mission(
    kind: MissionKind.quiz,
    points: 40,
    current: 5,
    target: 5,
    completed: true,
  );

  ProviderContainer containerWith(List<Mission> missions) {
    final container = ProviderContainer(
      overrides: [initialMissionsProvider.overrideWithValue(missions)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('derives completed count and weekly progress', () {
    final state = containerWith([pending, done])
        .read(weeklyMissionsViewModelProvider);
    expect(state.completedCount, 1);
    expect(state.weeklyProgress, 0.5);
  });

  test('empty mission list has zero progress', () {
    final state = containerWith(const []).read(weeklyMissionsViewModelProvider);
    expect(state.weeklyProgress, 0);
  });

  test('complete marks only the matching mission as done', () {
    final container = containerWith([pending, done]);
    container
        .read(weeklyMissionsViewModelProvider.notifier)
        .complete(MissionKind.journey);
    final missions = container.read(weeklyMissionsViewModelProvider).missions;
    expect(missions.every((m) => m.completed), isTrue);
    expect(missions.first.progress, 1);
    expect(pending.completed, isFalse);
  });

  test('toggles history, expansion and selected day', () {
    final container = containerWith([pending]);
    final viewModel = container.read(weeklyMissionsViewModelProvider.notifier);
    viewModel
      ..toggleHistory()
      ..setShowAllTasks(true)
      ..selectDay(5);
    final state = container.read(weeklyMissionsViewModelProvider);
    expect(state.showHistory, isTrue);
    expect(state.showAllTasks, isTrue);
    expect(state.selectedDay, 5);
  });
}
