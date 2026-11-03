import 'package:su_ky_mobile/features/weekly_missions/domain/mission.dart';

/// Demo data for the weekly missions screen; replace with an API-backed
/// repository once the backend exists.
abstract final class MockMissions {
  static const missions = <Mission>[
    Mission(
      kind: MissionKind.listen,
      points: 50,
      current: 30,
      target: 30,
      completed: true,
    ),
    Mission(
      kind: MissionKind.explore,
      points: 60,
      current: 2,
      target: 2,
      completed: true,
    ),
    Mission(
      kind: MissionKind.quiz,
      points: 40,
      current: 4,
      target: 5,
      completed: true,
    ),
    Mission(
      kind: MissionKind.journey,
      points: 70,
      current: 1,
      target: 3,
      opensDetail: true,
    ),
    Mission(kind: MissionKind.streak, points: 80, current: 3, target: 5),
  ];

  /// Day-of-month numbers of the displayed Monday..Sunday week.
  static const weekDates = [2, 3, 4, 5, 6, 7, 8];
  static const checkedInDays = 3;
  static const selectedDay = 2;
  static const totalPoints = 150;
  static const streakDays = 3;
}
