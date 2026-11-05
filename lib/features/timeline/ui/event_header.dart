import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/domain/historical_event.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

const _breadcrumbSpacing = 0.5;
const _timeGap = 8.0;
const _nameGap = 6.0;
const _summaryGap = 10.0;
const _bodyLineHeight = 1.7;

/// Top of the event detail page: period/phase path, date, name and summary.
class EventHeader extends StatelessWidget {
  const EventHeader({super.key, required this.event});

  final HistoricalEvent event;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.eventBreadcrumb(event.periodName, event.phaseName),
          style: context.text.labelSmall?.copyWith(
            color: AppDesign.muted,
            letterSpacing: _breadcrumbSpacing,
          ),
        ),
        const SizedBox(height: _timeGap),
        Text(
          event.timeLabel,
          style: context.text.labelLarge?.copyWith(
            color: context.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: _nameGap),
        Text(
          event.name,
          style: context.text.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: _summaryGap),
        Text(
          event.summary,
          style: context.text.bodySmall?.copyWith(height: _bodyLineHeight),
        ),
      ],
    );
  }
}
