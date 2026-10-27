import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../error/app_exception.dart';

const _connectTimeout = Duration(seconds: 10);
const _sendTimeout = Duration(seconds: 15);
const _receiveTimeout = Duration(seconds: 20);
const _serverErrorMin = 500;

/// Builds the single app HTTP client. Every request has timeouts; failures are
/// converted to [AppException] and carried in `DioException.error`.
Dio createDio(AppConfig config) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl.toString(),
      connectTimeout: _connectTimeout,
      sendTimeout: _sendTimeout,
      receiveTimeout: _receiveTimeout,
      headers: const {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (e, handler) =>
          handler.next(e.copyWith(error: mapDioException(e))),
    ),
  );
  return dio;
}

/// Retryable: timeouts, connectivity, 5xx. Not retryable: 4xx, cancel, rest.
AppException mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
    case DioExceptionType.connectionError:
      return NetworkException('Network unavailable', cause: e);
    case DioExceptionType.badResponse:
      final status = e.response?.statusCode ?? 0;
      return status >= _serverErrorMin
          ? NetworkException('Server error $status', cause: e)
          : ValidationException('Request rejected $status', cause: e);
    case DioExceptionType.badCertificate:
    case DioExceptionType.cancel:
    case DioExceptionType.unknown:
      return UnknownException(e.message ?? 'Unknown network error', cause: e);
  }
}
