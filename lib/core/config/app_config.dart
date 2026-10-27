/// Deployment environments. Selected at build time via `--dart-define=ENV=...`.
enum AppEnvironment {
  dev,
  staging,
  prod;

  static AppEnvironment parse(String raw) => AppEnvironment.values.firstWhere(
    (e) => e.name == raw,
    orElse: () => throw ArgumentError.value(
      raw,
      'ENV',
      'Expected one of ${AppEnvironment.values.map((e) => e.name)}',
    ),
  );
}

/// Immutable, build-time configuration. No secrets here: `--dart-define`
/// values are embedded in the binary and extractable.
class AppConfig {
  const AppConfig({required this.environment, required this.apiBaseUrl});

  static const appName = 'Sử Ký';

  /// Fails fast on an invalid `ENV` or missing/invalid `API_BASE_URL`.
  /// Supply values with `--dart-define-from-file=env/<env>.json`.
  factory AppConfig.fromEnvironment() => AppConfig(
    environment: AppEnvironment.parse(
      const String.fromEnvironment('ENV', defaultValue: 'dev'),
    ),
    apiBaseUrl: parseApiBaseUrl(const String.fromEnvironment('API_BASE_URL')),
  );

  final AppEnvironment environment;
  final Uri apiBaseUrl;

  bool get isProduction => environment == AppEnvironment.prod;

  static Uri parseApiBaseUrl(String raw) {
    final uri = Uri.tryParse(raw);
    final valid =
        uri != null &&
        uri.hasAuthority &&
        (uri.scheme == 'https' || uri.scheme == 'http');
    if (!valid) {
      throw ArgumentError.value(
        raw,
        'API_BASE_URL',
        'Expected absolute http(s) URL; pass --dart-define-from-file=env/dev.json',
      );
    }
    return uri;
  }
}
