import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
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
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: context.text.titleLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              minimumSize: const Size(0, AppDesign.tapTarget),
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
