/// One page of a server list: `{items, page, limit, total}`.
final class Paged<T> {
  const Paged({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
  });

  final List<T> items;
  final int page;
  final int limit;
  final int total;

  bool get hasMore => page * limit < total;
}
