import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/catalog/domain/historical_event.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

const _citationGap = 12.0;
const _lineGap = 4.0;
const _excerptGap = 10.0;
const _excerptPadding = 12.0;
const _excerptRadius = 10.0;
const _excerptLineHeight = 1.6;
const _sourceTitleMaxLines = 1;

/// Sources backing an event. Hidden entirely when the event has none.
class EventCitations extends StatelessWidget {
  const EventCitations({super.key, required this.citations});

  final List<EventCitation> citations;

  @override
  Widget build(BuildContext context) {
    if (citations.isEmpty) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(l.eventSourcesTitle),
        for (final citation in citations)
          Padding(
            padding: const EdgeInsets.only(bottom: _citationGap),
            child: _CitationCard(citation: citation),
          ),
      ],
    );
  }
}

class _CitationCard extends StatelessWidget {
  const _CitationCard({required this.citation});

  final EventCitation citation;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final excerpt = citation.excerpt;
    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            citation.sourceTitle,
            maxLines: _sourceTitleMaxLines,
            overflow: TextOverflow.ellipsis,
            style: context.text.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: _lineGap),
          Text(
            l.eventSourceLine(
              citation.sourceAuthor ?? l.eventSourceFallbackAuthor,
              citation.locator,
            ),
            style: context.text.bodySmall?.copyWith(color: AppDesign.muted),
          ),
          if (excerpt != null) ...[
            const SizedBox(height: _excerptGap),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(_excerptPadding),
              decoration: BoxDecoration(
                color: AppDesign.tint,
                borderRadius: BorderRadius.circular(_excerptRadius),
              ),
              child: Text(
                excerpt,
                style: context.text.bodySmall?.copyWith(
                  height: _excerptLineHeight,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
