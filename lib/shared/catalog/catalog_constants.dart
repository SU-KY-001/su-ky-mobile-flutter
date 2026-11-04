/// Catalog tuning values shared by the data layer and providers.
abstract final class CatalogDefaults {
  static const seriesPageSize = 20;

  /// One page of historical events. The server caps the limit at 50 and the
  /// public history holds far fewer, so there is no pagination (P9).
  static const eventsLimit = 50;

  /// How many series the "latest episodes" block scans (RN `podcastApi.ts`).
  static const latestSeriesScanCount = 6;
  static const latestEpisodesCount = 6;

  /// Matches the RN query client `staleTime`.
  static const staleTime = Duration(seconds: 60);

  /// Banner series of the RN Podcast tab (`PodcastScreens.tsx`). Falls back to
  /// the first series when the environment does not have it.
  static const featuredSeriesSlug = 'viet-nam-thoi-phong-kien';

  /// Server slugs are lowercase kebab-case; anything else never reaches the API.
  static final slugPattern = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');
}

bool isValidSlug(String value) => CatalogDefaults.slugPattern.hasMatch(value);
