import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:su_ky_mobile/core/error/app_exception.dart';
import 'package:su_ky_mobile/core/network/dio_factory.dart';

DioException _bad(int status) {
  final req = RequestOptions(path: '/x');
  return DioException(
    requestOptions: req,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: req, statusCode: status),
  );
}

void main() {
  test('5xx and timeouts are retryable', () {
    expect(mapDioException(_bad(503)).isRetryable, isTrue);
    final timeout = DioException(
      requestOptions: RequestOptions(path: '/x'),
      type: DioExceptionType.receiveTimeout,
    );
    expect(mapDioException(timeout).isRetryable, isTrue);
  });

  test('4xx is a non-retryable ValidationException', () {
    final e = mapDioException(_bad(400));
    expect(e, isA<ValidationException>());
    expect(e.isRetryable, isFalse);
  });
}
