import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../error/app_exception.dart';
import '../storage/token_store.dart';
import 'auth_interceptor.dart';

const _connectTimeout = Duration(seconds: 10);
const _sendTimeout = Duration(seconds: 15);
const _receiveTimeout = Duration(seconds: 20);
const _serverErrorMin = 500;

/// Builds the single app HTTP client. Every request has timeouts; failures are
/// converted to [AppException] and carried in `DioException.error`.
Dio createDio(AppConfig config, {TokenStore? tokens}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl.toString(),
      connectTimeout: _connectTimeout,
      sendTimeout: _sendTimeout,
      receiveTimeout: _receiveTimeout,
      headers: const {'Accept': 'application/json'},
    ),
  );
  if (tokens != null) dio.interceptors.add(AuthInterceptor(tokens));
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
      if (status >= _serverErrorMin) {
        return NetworkException('Server error $status', cause: e);
      }
      final (code, message) = _readApiError(e.response?.data);
      return ApiException(
        message ?? 'Request rejected $status',
        statusCode: status,
        errorCode: code,
        cause: e,
      );
    case DioExceptionType.badCertificate:
    case DioExceptionType.cancel:
    case DioExceptionType.unknown:
      return UnknownException(e.message ?? 'Unknown network error', cause: e);
  }
}

/// API errors are `{error_code, message}` or, under /api/auth, `{code, message}`.
(String?, String?) _readApiError(Object? body) {
  if (body is! Map<String, dynamic>) return (null, null);
  final code = body['error_code'] ?? body['code'];
  final message = body['message'];
  return (code is String ? code : null, message is String ? message : null);
}
