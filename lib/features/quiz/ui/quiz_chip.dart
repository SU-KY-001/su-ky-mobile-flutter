import 'package:flutter/material.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

/// One selectable chip, same compact style as the Home period chips; shared by
/// the topic filter and the review filter.
class QuizChoiceChip extends StatelessWidget {
  const QuizChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => ChoiceChip(
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
    label: Text(
      label,
      style: TextStyle(
        fontFamily: 'Inter',
        color: selected ? AppDesign.white : AppDesign.ink,
      ),
    ),
    selected: selected,
    onSelected: (_) => onSelected(),
  );
}
