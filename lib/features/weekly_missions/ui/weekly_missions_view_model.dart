import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/features/weekly_missions/data/mock_missions.dart';
import 'package:su_ky_mobile/features/weekly_missions/domain/mission.dart';

/// Source of the week's missions; override in tests or with an API-backed
/// repository once available.
final initialMissionsProvider = Provider<List<Mission>>(
  (ref) => MockMissions.missions,
);

class WeeklyMissionsState {
  const WeeklyMissionsState({
    required this.missions,
    required this.weekDates,
    required this.checkedInDays,
    required this.selectedDay,
    required this.totalPoints,
    required this.streakDays,
    this.showHistory = false,
    this.showAllTasks = false,
  });

  final List<Mission> missions;
  final List<int> weekDates;
  final int checkedInDays;
  final int selectedDay;
  final int totalPoints;
  final int streakDays;
  final bool showHistory;
  final bool showAllTasks;

  int get completedCount => missions.where((m) => m.completed).length;

  double get weeklyProgress =>
      missions.isEmpty ? 0 : completedCount / missions.length;

  WeeklyMissionsState copyWith({
    List<Mission>? missions,
    int? selectedDay,
    bool? showHistory,
    bool? showAllTasks,
  }) => WeeklyMissionsState(
    missions: missions ?? this.missions,
    weekDates: weekDates,
    checkedInDays: checkedInDays,
    selectedDay: selectedDay ?? this.selectedDay,
    totalPoints: totalPoints,
    streakDays: streakDays,
    showHistory: showHistory ?? this.showHistory,
    showAllTasks: showAllTasks ?? this.showAllTasks,
  );
}

class WeeklyMissionsViewModel extends Notifier<WeeklyMissionsState> {
  @override
  WeeklyMissionsState build() => WeeklyMissionsState(
    missions: List.unmodifiable(ref.watch(initialMissionsProvider)),
    weekDates: MockMissions.weekDates,
    checkedInDays: MockMissions.checkedInDays,
    selectedDay: MockMissions.selectedDay,
    totalPoints: MockMissions.totalPoints,
    streakDays: MockMissions.streakDays,
  );

  void selectDay(int index) => state = state.copyWith(selectedDay: index);

  void toggleHistory() =>
      state = state.copyWith(showHistory: !state.showHistory);

  void setShowAllTasks(bool value) =>
      state = state.copyWith(showAllTasks: value);

  void complete(MissionKind kind) => state = state.copyWith(
    missions: List.unmodifiable([
      for (final mission in state.missions)
        mission.kind == kind ? mission.copyWith(completed: true) : mission,
    ]),
  );
}

final weeklyMissionsViewModelProvider =
    NotifierProvider.autoDispose<WeeklyMissionsViewModel, WeeklyMissionsState>(
      WeeklyMissionsViewModel.new,
    );
