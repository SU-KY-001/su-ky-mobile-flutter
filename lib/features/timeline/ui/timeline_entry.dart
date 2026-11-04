import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';
import 'package:su_ky_mobile/features/timeline/ui/timeline_colors.dart';
import 'package:su_ky_mobile/shared/catalog/domain/historical_event.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

const _railWidth = 60.0;
const _railLineWidth = 2.0;
const _dotSize = 14.0;
const _dotBorderWidth = 2.0;
const _dotTop = 14.0;
const _labelGap = 6.0;
const _axisFontSize = 10.0;
const _axisLineHeight = 1.2;
const _rowMinHeight = 96.0;
const _rowPadding = 12.0;
const _titleGap = 4.0;
const _titleMaxLines = 2;
const _summaryMaxLines = 2;

/// Server-formatted labels prefix approximate years with this word; the axis
/// drops it, as RN does.
const _approximatePrefix = 'Khoảng ';

/// One row of the vertical timeline: a rail with the date and a compact
/// event row that opens the event detail. Events carry no image, so there is
/// no thumbnail.
class TimelineEntry extends StatelessWidget {
  const TimelineEntry({
    super.key,
    required this.event,
    required this.first,
    required this.last,
  });

  final HistoricalEvent event;
  final bool first;
  final bool last;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: _railWidth,
          child: _TimelineRail(
            label: _axisLabel(event.timeLabel),
            first: first,
            last: last,
          ),
        ),
        Expanded(child: _EventRow(event: event)),
      ],
    ),
  );
}

String _axisLabel(String timeLabel) =>
    timeLabel.replaceAll(_approximatePrefix, '');

class _TimelineRail extends StatelessWidget {
  const _TimelineRail({
    required this.label,
    required this.first,
    required this.last,
  });

  final String label;
  final bool first;
  final bool last;

  @override
  Widget build(BuildContext context) {
    const center = _dotTop + _dotSize / 2;
    const lineLeft = (_railWidth - _railLineWidth) / 2;
    return Stack(
      children: [
        if (!first)
          const Positioned(
            top: 0,
            height: center,
            left: lineLeft,
            child: _RailLine(),
          ),
        if (!last)
          const Positioned(
            top: center,
            bottom: 0,
            left: lineLeft,
            child: _RailLine(),
          ),
        Positioned(
          top: _dotTop,
          left: (_railWidth - _dotSize) / 2,
          child: _Dot(first: first),
        ),
        Positioned(
          top: _dotTop + _dotSize + _labelGap,
          left: 0,
          right: 0,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: _titleMaxLines,
            overflow: TextOverflow.ellipsis,
            style: context.text.labelSmall?.copyWith(
              color: AppDesign.muted,
              fontSize: _axisFontSize,
              height: _axisLineHeight,
            ),
          ),
        ),
      ],
    );
  }
}

class _RailLine extends StatelessWidget {
  const _RailLine();

  @override
  Widget build(BuildContext context) =>
      Container(width: _railLineWidth, color: AppDesign.line);
}

class _Dot extends StatelessWidget {
  const _Dot({required this.first});

  final bool first;

  @override
  Widget build(BuildContext context) => Container(
    width: _dotSize,
    height: _dotSize,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: first ? context.accent : AppDesign.canvas,
      border: first
          ? null
          : Border.all(color: TimelineColors.bronze, width: _dotBorderWidth),
    ),
  );
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});

  final HistoricalEvent event;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => context.push(AppRoutes.eventFor(event.slug)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: _rowMinHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: _rowPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.name,
              maxLines: _titleMaxLines,
              overflow: TextOverflow.ellipsis,
              style: context.text.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: _titleGap),
            Text(
              event.summary,
              maxLines: _summaryMaxLines,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodySmall?.copyWith(color: AppDesign.muted),
            ),
          ],
        ),
      ),
    ),
  );
}
