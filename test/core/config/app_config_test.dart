import 'package:flutter_test/flutter_test.dart';
import 'package:su_ky_mobile/core/config/app_config.dart';

void main() {
  test('parses known environments', () {
    expect(AppEnvironment.parse('prod'), AppEnvironment.prod);
  });

  test('rejects unknown environment (fail fast)', () {
    expect(() => AppEnvironment.parse('prd'), throwsArgumentError);
  });

  test('accepts absolute http(s) API url', () {
    expect(
      AppConfig.parseApiBaseUrl('https://api.example.com/v1/').host,
      'api.example.com',
    );
  });

  test('rejects empty, relative and non-http API url', () {
    for (final bad in ['', '/v1', 'ftp://x.com', 'api.example.com']) {
      expect(
        () => AppConfig.parseApiBaseUrl(bad),
        throwsArgumentError,
        reason: bad,
      );
    }
  });
}
