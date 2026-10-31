import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

abstract final class MissionDesign {
  static const gold = Color(0xFF866408);
  static const paleGold = Color(0xFFFFF0CF);
  static const green = Color(0xFF155C46);
  static const paleGreen = Color(0xFFD9F2E4);
  static const headingSize = 25.0;
  static const sectionSize = 20.0;
  static const badgeSize = 136.0;
  static const progress = 1 / 3;
  static const contentPadding = EdgeInsets.all(16);
  static const smallGap = SizedBox(height: 8);
  static const gap = SizedBox(height: AppDesign.gap);
  static const sectionGap = SizedBox(height: AppDesign.pagePadding);

  static TextStyle heading(BuildContext context, {double size = headingSize}) =>
      context.text.headlineSmall!.copyWith(
        fontFamily: 'Inter',
        fontSize: size,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: AppDesign.ink,
      );

  static void showPreviewNotice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).missionSampleNotice)),
    );
  }
}

class MissionHeader extends StatelessWidget {
  const MissionHeader({
    super.key,
    required this.title,
    required this.onBack,
    required this.onHonours,
    required this.onProfile,
  });
  final String title;
  final VoidCallback onBack, onHonours, onProfile;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        IconButton(
          tooltip: l.back,
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_ios_new, color: AppDesign.red),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: MissionDesign.heading(
              context,
              size: MissionDesign.sectionSize,
            ),
          ),
        ),
        IconButton(
          tooltip: l.honoursTitle,
          onPressed: onHonours,
          icon: const Icon(
            Icons.military_tech_outlined,
            color: MissionDesign.gold,
          ),
        ),
        IconButton.filled(
          tooltip: l.profile,
          onPressed: onProfile,
          style: IconButton.styleFrom(backgroundColor: AppDesign.red),
          icon: const Icon(Icons.person_outline),
        ),
      ],
    );
  }
}

class MissionFooter extends StatelessWidget {
  const MissionFooter({
    super.key,
    required this.label,
    required this.onPressed,
    this.secondaryLabel,
    this.onSecondary,
    this.footnote,
  });
  final String label;
  final VoidCallback onPressed;
  final String? secondaryLabel, footnote;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Align(
      heightFactor: 1,
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppDesign.maxWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDesign.pagePadding,
            8,
            AppDesign.pagePadding,
            8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onPressed,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(label, textAlign: TextAlign.center),
                  ),
                ),
              ),
              if (secondaryLabel != null)
                TextButton(
                  onPressed: onSecondary,
                  child: Text(
                    secondaryLabel!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: MissionDesign.gold),
                  ),
                ),
              if (footnote != null) ...[
                MissionDesign.smallGap,
                Text(
                  footnote!,
                  textAlign: TextAlign.center,
                  style: context.text.labelSmall?.copyWith(
                    color: AppDesign.muted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

class MissionSectionHeading extends StatelessWidget {
  const MissionSectionHeading({
    super.key,
    required this.title,
    required this.caption,
  });
  final String title, caption;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppDesign.gap,
      runSpacing: 8,
      children: [
        Text(
          title,
          style: MissionDesign.heading(
            context,
            size: MissionDesign.sectionSize,
          ),
        ),
        Text(
          caption,
          style: context.text.labelSmall?.copyWith(color: MissionDesign.gold),
        ),
      ],
    ),
  );
}
