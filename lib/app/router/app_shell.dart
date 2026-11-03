import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/shared/audio/audio_view_model.dart';
import 'package:su_ky_mobile/shared/widgets/main_navigation.dart';
import 'package:su_ky_mobile/shared/widgets/mini_player.dart';

import 'app_routes.dart';

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
    final loaded = ref.watch(audioViewModelProvider.select((s) => s.loaded));
    final current = navigationShell.currentIndex;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loaded) MiniPlayer(onOpen: () => context.push(AppRoutes.player)),
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
