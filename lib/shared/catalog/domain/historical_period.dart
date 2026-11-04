final class HistoricalPeriod {
  const HistoricalPeriod({
    required this.id,
    required this.slug,
    required this.name,
    this.startYear,
    this.endYear,
  });

  final String id;
  final String slug;
  final String name;
  final int? startYear;
  final int? endYear;
}
