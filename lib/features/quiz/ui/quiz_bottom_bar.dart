import 'package:flutter/material.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

const _buttonHeight = 56.0;
const _barPadding = EdgeInsets.fromLTRB(
  AppDesign.pagePadding,
  8,
  AppDesign.pagePadding,
  AppDesign.pagePadding,
);

/// Sticky bottom action of every quiz stage: one full-width filled button
/// (Duolingo CHECK / CONTINUE) with optional text actions underneath.
class QuizBottomBar extends StatelessWidget {
  const QuizBottomBar({
    super.key,
    required this.label,
    required this.onPressed,
    this.secondary = const [],
  });

  final String label;

  /// `null` renders the button disabled.
  final VoidCallback? onPressed;
  final List<Widget> secondary;

  @override
  Widget build(BuildContext context) => Padding(
    padding: _barPadding,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(_buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDesign.radius),
            ),
          ),
          child: Text(label),
        ),
        ...secondary,
      ],
    ),
  );
}
