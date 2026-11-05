import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/missions/domain/weekly_missions.dart';

/// UI-only mapping of mission enums: the domain stays free of Flutter types.
extension MissionPresentation on WeeklyMission {
  IconData get icon => switch (activity) {
    MissionActivity.completeEpisode => Symbols.headphones,
    MissionActivity.passQuiz => Symbols.emoji_events,
  };

  /// What the user must do, derived from type and target: the server only
  /// sends a short title, which does not say how to finish the mission.
  String howTo(AppLocalizations l) => switch (activity) {
    MissionActivity.completeEpisode => l.missionsHowEpisode(targetCount),
    MissionActivity.passQuiz => l.missionsHowQuiz(targetCount),
  };
}

extension MissionStatusPresentation on MissionStatus {
  /// Null while in progress; only finished/expired missions show a chip.
  String? label(AppLocalizations l) => switch (this) {
    MissionStatus.inProgress => null,
    MissionStatus.completed => l.missionsStatusCompleted,
    MissionStatus.expired => l.missionsStatusExpired,
  };
}
