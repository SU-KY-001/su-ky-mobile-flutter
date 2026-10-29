import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/audio_view_model.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

class AppPage extends StatelessWidget {
  const AppPage({super.key, required this.child, this.bottom, this.appBar});
  final Widget child;
  final Widget? bottom;
  final PreferredSizeWidget? appBar;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: appBar,
    body: SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDesign.maxWidth),
          child: child,
        ),
      ),
    ),
    bottomNavigationBar: bottom,
  );
}

class Surface extends StatelessWidget {
  const Surface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.selected = false,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool selected;
  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppDesign.tint : AppDesign.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDesign.radius),
      side: BorderSide(
        color: selected ? AppDesign.red.withValues(alpha: .3) : AppDesign.line,
      ),
    ),
    child: Padding(padding: padding, child: child),
  );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.action, this.onTap});
  final String title;
  final String? action;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 24),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(action!),
          ),
      ],
    ),
  );
}

class RoundPlay extends StatelessWidget {
  const RoundPlay({
    super.key,
    required this.onTap,
    this.playing = false,
    this.size = 42,
    this.filled = true,
  });
  final VoidCallback onTap;
  final bool playing;
  final double size;
  final bool filled;
  @override
  Widget build(BuildContext context) => IconButton.filled(
    style: IconButton.styleFrom(
      minimumSize: Size.square(size),
      backgroundColor: filled ? context.accent : AppDesign.tint,
      foregroundColor: filled ? AppDesign.white : context.accent,
    ),
    tooltip: playing
        ? AppLocalizations.of(context).pause
        : AppLocalizations.of(context).play,
    onPressed: onTap,
    icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
  );
}

class MainNavigation extends StatelessWidget {
  const MainNavigation({
    super.key,
    required this.index,
    required this.onDiscover,
    required this.onSearch,
    required this.onProfile,
  });
  final int index;
  final VoidCallback onDiscover;
  final VoidCallback onSearch;
  final VoidCallback onProfile;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (value) =>
          [onDiscover, onSearch, onProfile][value](),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.explore_outlined),
          label: l.discover,
        ),
        NavigationDestination(icon: const Icon(Icons.search), label: l.search),
        NavigationDestination(
          icon: const Icon(Icons.account_circle_outlined),
          label: l.profile,
        ),
      ],
    );
  }
}

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key, required this.onOpen});
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioViewModelProvider);
    final controller = ref.read(audioViewModelProvider.notifier);
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Surface(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: state.progress,
              minHeight: 2,
              color: context.accent,
              backgroundColor: AppDesign.line,
            ),
            ListTile(
              dense: true,
              onTap: onOpen,
              leading: Icon(Icons.menu_book_outlined, color: context.accent),
              title: Text(
                l.playerTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(l.ngoDynasty),
              trailing: RoundPlay(
                onTap: controller.toggle,
                playing: state.playing,
                size: 36,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String episodeTitle(AppLocalizations l, int index) => [
  l.episode1,
  l.episode2,
  l.episode3,
  l.episode4,
  l.episode5,
  l.episode6,
][index];

class CoverArt extends StatelessWidget {
  const CoverArt({
    super.key,
    this.path = AppDesign.cover,
    this.height = 170,
    this.width,
  });
  final String path;
  final double height;
  final double? width;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: Image.asset(
      path,
      height: height,
      width: width ?? double.infinity,
      fit: BoxFit.cover,
    ),
  );
}
