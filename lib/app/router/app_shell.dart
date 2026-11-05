import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/shared/audio/playback_controller.dart';
import 'package:su_ky_mobile/shared/widgets/main_navigation.dart';
import 'package:su_ky_mobile/shared/widgets/mini_player.dart';

/// Tab bar and mini-player shared by every tab branch.
class AppShell extends ConsumerWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
    required this.tabs,
  });

  final StatefulNavigationShell navigationShell;

  /// One entry per branch, in branch order.
  final List<AppTab> tabs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasEpisode = ref.watch(
      playbackControllerProvider.select((state) => state.hasEpisode),
    );
    final current = navigationShell.currentIndex;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasEpisode) const MiniPlayer(),
          MainNavigation(
            tabs: tabs,
            selected: tabs[current],
            onSelect: (tab) {
              final index = tabs.indexOf(tab);
              navigationShell.goBranch(
                index,
                initialLocation: index == current,
              );
            },
          ),
        ],
      ),
    );
  }
}
