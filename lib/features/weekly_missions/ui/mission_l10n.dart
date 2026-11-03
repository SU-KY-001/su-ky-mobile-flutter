import 'package:flutter/material.dart';
import 'package:su_ky_mobile/features/weekly_missions/domain/mission.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';

/// Resolves localized copy and the icon for a [Mission].
extension MissionPresentation on Mission {
  IconData get icon => switch (kind) {
    MissionKind.listen => Icons.headphones_outlined,
    MissionKind.explore => Icons.menu_book_outlined,
    MissionKind.quiz => Icons.assignment_outlined,
    MissionKind.journey => Icons.hearing_outlined,
    MissionKind.streak => Icons.local_fire_department_outlined,
  };

  String title(AppLocalizations l) => switch (kind) {
    MissionKind.listen => l.missionsListenTitle,
    MissionKind.explore => l.missionsExploreTitle,
    MissionKind.quiz => l.missionsQuizTitle,
    MissionKind.journey => l.missionsJourneyTitle,
    MissionKind.streak => l.missionsStreakTitle,
  };

  String subtitle(AppLocalizations l) => switch (kind) {
    MissionKind.listen => l.missionsListenSubtitle,
    MissionKind.explore => l.missionsExploreSubtitle,
    MissionKind.quiz => l.missionsQuizSubtitle,
    MissionKind.journey => l.missionsJourneySubtitle,
    MissionKind.streak => l.missionsStreakSubtitle,
  };

  String detail(AppLocalizations l) => switch (kind) {
    MissionKind.listen => l.missionsListenDetail(current, target),
    MissionKind.explore => l.missionsExploreDetail(current, target),
    MissionKind.quiz => l.missionsQuizDetail(current, target),
    MissionKind.journey => l.missionsJourneyDetail(current, target),
    MissionKind.streak => l.missionsStreakDetail(current, target),
  };
}
