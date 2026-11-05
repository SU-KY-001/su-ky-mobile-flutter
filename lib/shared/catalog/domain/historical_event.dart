/// One historical event from `/api/historical-events`.
///
/// The list and the detail endpoint return the same shape, so one model
/// serves both. Pure Dart: no Flutter types.
final class HistoricalEvent {
  const HistoricalEvent({
    required this.id,
    required this.slug,
    required this.name,
    required this.summary,
    required this.timeLabel,
    required this.periodName,
    required this.phaseName,
    required this.citations,
  });

  final String id;
  final String slug;
  final String name;
  final String summary;

  /// Server-formatted date range, used verbatim (it carries BCE years).
  final String timeLabel;
  final String periodName;
  final String phaseName;
  final List<EventCitation> citations;
}

/// One historical source backing an event.
final class EventCitation {
  const EventCitation({
    required this.locator,
    required this.sourceTitle,
    this.excerpt,
    this.sourceAuthor,
  });

  /// Where in the source the claim comes from.
  final String locator;
  final String sourceTitle;
  final String? excerpt;
  final String? sourceAuthor;
}
