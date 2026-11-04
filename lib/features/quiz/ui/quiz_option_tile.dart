import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

import '../domain/quiz.dart';

const _tileMinHeight = 56.0;
const _borderWidth = 2.0;
const _tilePadding = EdgeInsets.symmetric(horizontal: 16, vertical: 14);
const _iconGap = 12.0;
const _tintAlpha = .08;
const _textSize = 16.0;

/// Duolingo choice tile: 2 px border, accent border + tint + filled radio
/// when selected.
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
    final accent = context.accent;
    return Material(
      color: selected ? accent.withValues(alpha: _tintAlpha) : AppDesign.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesign.radius),
        side: BorderSide(
          color: selected ? accent : AppDesign.line,
          width: _borderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onSelect(option.id),
        child: Semantics(
          selected: selected,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _tileMinHeight),
            child: Padding(
              padding: _tilePadding,
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: selected ? accent : AppDesign.muted,
                  ),
                  const SizedBox(width: _iconGap),
                  Expanded(
                    child: Text(
                      l.quizOptionLine(option.label, option.text),
                      style: TextStyle(
                        fontSize: _textSize,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
