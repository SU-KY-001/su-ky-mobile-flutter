import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';

/// Bottom-bar destinations, in display order of the RN app. Profile is not a
/// destination: it opens from the avatar in the top-right corner.
enum AppTab {
  discover(Icons.home_outlined),
  history(Icons.menu_book_outlined),
  podcast(Icons.mic_none),
  quiz(Icons.emoji_events_outlined);

  const AppTab(this.icon);
  final IconData icon;

  String label(AppLocalizations l) => switch (this) {
    discover => l.discover,
    history => l.tabHistory,
    podcast => l.tabPodcast,
    quiz => l.tabQuiz,
  };
}

class MainNavigation extends StatelessWidget {
  const MainNavigation({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onSelect,
  });

  final List<AppTab> tabs;
  final AppTab selected;
  final ValueChanged<AppTab> onSelect;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return NavigationBar(
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      selectedIndex: tabs.indexOf(selected),
      onDestinationSelected: (value) => onSelect(tabs[value]),
      destinations: [
        for (final tab in tabs)
          NavigationDestination(icon: Icon(tab.icon), label: tab.label(l)),
      ],
    );
  }
}
