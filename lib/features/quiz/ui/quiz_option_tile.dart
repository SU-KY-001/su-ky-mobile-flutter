import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

import '../domain/quiz.dart';
import 'quiz_colors.dart';

const _optionRadius = 16.0;
const _optionBorderWidth = 1.0;
const _selectedBorderWidth = 2.0;
const _optionPadding = 18.0;
const _optionGap = 12.0;
const _optionLineHeight = 1.6;

class QuizOptionTile extends StatelessWidget {
  const QuizOptionTile({
    super.key,
    required this.option,
    required this.selected,
    required this.onSelect,
  });

  final QuizOption option;
  final bool selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final color = selected ? AppDesign.red : AppDesign.line;
    return Material(
      color: selected ? AppDesign.tint : AppDesign.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_optionRadius),
        side: BorderSide(
          color: color,
          width: selected ? _selectedBorderWidth : _optionBorderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onSelect(option.id),
        child: Semantics(
          selected: selected,
          child: Padding(
            padding: const EdgeInsets.all(_optionPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected ? QuizColors.green : AppDesign.muted,
                ),
                const SizedBox(width: _optionGap),
                Expanded(
                  child: Text(
                    l.quizOptionLine(option.label, option.text),
                    style: TextStyle(
                      height: _optionLineHeight,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
