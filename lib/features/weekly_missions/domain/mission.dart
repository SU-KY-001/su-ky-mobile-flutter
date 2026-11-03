/// Identifies a mission; the UI maps it to localized copy and an icon.
enum MissionKind { listen, explore, quiz, journey, streak }

class Mission {
  const Mission({
    required this.kind,
    required this.points,
    required this.current,
    required this.target,
    this.completed = false,
    this.opensDetail = false,
  });

  final MissionKind kind;
  final int points;
  final int current;
  final int target;
  final bool completed;

  /// Whether tapping the mission opens its dedicated detail screen.
  final bool opensDetail;

  double get progress {
    if (completed) return 1;
    if (target == 0) return 0;
    return (current / target).clamp(0.0, 1.0);
  }

  Mission copyWith({int? current, bool? completed}) => Mission(
    kind: kind,
    points: points,
    current: current ?? this.current,
    target: target,
    completed: completed ?? this.completed,
    opensDetail: opensDetail,
  );
}
