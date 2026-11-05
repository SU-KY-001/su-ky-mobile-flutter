import 'package:flutter/material.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

const _labelTopGap = 24.0;
const _labelBottomGap = 8.0;

/// Small muted label that starts a group of rows (YouTube "Settings" label).
class ProfileSectionLabel extends StatelessWidget {
  const ProfileSectionLabel(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: _labelTopGap, bottom: _labelBottomGap),
    child: Text(
      title,
      style: context.text.labelMedium?.copyWith(
        color: AppDesign.muted,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

/// Rounded container that groups related rows with hairline dividers, so a
/// profile group reads as one block instead of loose flat rows.
class ProfileGroup extends StatelessWidget {
  const ProfileGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: AppDesign.white,
      borderRadius: BorderRadius.circular(AppDesign.radius),
      border: Border.all(color: AppDesign.line),
    ),
    child: Column(
      children: [
        for (var index = 0; index < children.length; index++) ...[
          if (index > 0) const Divider(height: 1),
          children[index],
        ],
      ],
    ),
  );
}
