import 'package:dio/dio.dart';

import '../storage/token_store.dart';

const _authorizationHeader = 'Authorization';
const _bearerPrefix = 'Bearer ';
// A wrong password is a 401 too; it must not wipe an unrelated session.
const _credentialPaths = ['/api/auth/sign-in', '/api/auth/sign-up'];

/// Adds the Bearer token and drops the stored session when the server rejects it.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokens);

  final TokenStore _tokens;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokens.current;
    if (token != null && !options.headers.containsKey(_authorizationHeader)) {
      options.headers[_authorizationHeader] = '$_bearerPrefix$token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final sentBearer = options.headers.containsKey(_authorizationHeader);
    final isCredentialCall = _credentialPaths.any(options.path.startsWith);
    if (err.response?.statusCode == 401 && sentBearer && !isCredentialCall) {
      await _tokens.clear();
    }
    handler.next(err);
  }
}
