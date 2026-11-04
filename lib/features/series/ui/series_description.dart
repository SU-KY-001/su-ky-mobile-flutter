import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

const _collapsedLines = 3;

/// Show-page description: 3 lines with a "Xem thêm" toggle. The toggle only
/// appears when the text really overflows.
class SeriesDescription extends StatefulWidget {
  const SeriesDescription({super.key, required this.text});

  final String text;

  @override
  State<SeriesDescription> createState() => _SeriesDescriptionState();
}

class _SeriesDescriptionState extends State<SeriesDescription> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final style = context.text.bodyMedium;
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: _collapsedLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;
        painter.dispose();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              maxLines: _expanded ? null : _collapsedLines,
              overflow: _expanded ? null : TextOverflow.ellipsis,
              style: style,
            ),
            if (overflows)
              TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(
                  _expanded ? l.seriesDescriptionLess : l.seriesDescriptionMore,
                ),
              ),
          ],
        );
      },
    );
  }
}
