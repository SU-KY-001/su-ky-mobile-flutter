/// What the user must do to finish a weekly mission.
enum MissionActivity { completeEpisode, passQuiz }

enum MissionStatus { inProgress, completed, expired }

final class WeeklyMission {
  const WeeklyMission({
    required this.id,
    required this.title,
    required this.activity,
    required this.targetCount,
    required this.progressCount,
    required this.xpReward,
    required this.status,
  });

  final String id;
  final String title;
  final MissionActivity activity;
  final int targetCount;
  final int progressCount;
  final int xpReward;
  final MissionStatus status;

  /// The server keeps counting after the target is met (3 episodes on a
  /// 1-episode mission); the UI shows the capped value so it never reads "3/1".
  int get shownCount =>
      progressCount > targetCount ? targetCount : progressCount;

  /// Fraction in `[0, 1]`; a zero target means no measurable progress.
  double get progress {
    if (targetCount == 0) return 0;
    return (progressCount / targetCount).clamp(0.0, 1.0).toDouble();
  }
}

final class WeeklyMissions {
  const WeeklyMissions({
    required this.totalXp,
    required this.weekEnd,
    required this.items,
  });

  final int totalXp;

  /// End of the anchored week, always UTC.
  final DateTime weekEnd;
  final List<WeeklyMission> items;

  int get completedCount =>
      items.where((item) => item.status == MissionStatus.completed).length;
}
