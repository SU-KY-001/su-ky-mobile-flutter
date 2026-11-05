import 'package:flutter/material.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

const _barHeight = 10.0;
const _barRadius = 5.0;

/// Thick rounded lesson progress bar shown in the quiz app bar.
class QuizProgressBar extends StatelessWidget {
  const QuizProgressBar({super.key, required this.value});

  /// Fraction in `0..1`.
  final double value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: AppDesign.pagePadding),
    child: LinearProgressIndicator(
      value: value,
      minHeight: _barHeight,
      borderRadius: BorderRadius.circular(_barRadius),
      backgroundColor: AppDesign.line,
    ),
  );
}
