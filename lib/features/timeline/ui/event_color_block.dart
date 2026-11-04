import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

const _defaultHeight = 120.0;
const _iconSize = 40.0;
const _iconOpacity = 0.45;

/// Stand-in for the artwork an event does not have. The API sends no image
/// for historical events, so the block carries the accent colour instead.
class EventColorBlock extends StatelessWidget {
  const EventColorBlock({super.key, this.height = _defaultHeight});

  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: height,
      width: double.infinity,
      alignment: Alignment.center,
      color: scheme.primaryContainer,
      child: Icon(
        Symbols.history_edu,
        size: _iconSize,
        color: scheme.onPrimaryContainer.withValues(alpha: _iconOpacity),
      ),
    );
  }
}
