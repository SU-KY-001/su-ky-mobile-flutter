import 'package:flutter/material.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

const _chipHorizontalPadding = 14.0;
const _chipVerticalPadding = 8.0;

/// One selectable pill, shared by the topic filter and the review filter.
class QuizChoiceChip extends StatelessWidget {
  const QuizChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.selectedColor = AppDesign.ink,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(
      label,
      style: TextStyle(
        fontFamily: 'Inter',
        color: selected ? AppDesign.white : AppDesign.ink,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
    ),
    selected: selected,
    selectedColor: selectedColor,
    onSelected: (_) => onSelected(),
    padding: const EdgeInsets.symmetric(
      horizontal: _chipHorizontalPadding,
      vertical: _chipVerticalPadding,
    ),
  );
}
