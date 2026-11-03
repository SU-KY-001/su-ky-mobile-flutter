import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session_user.dart';
import '../../../core/di/providers.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/result.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/network/dio_factory.dart';

const _signInPath = '/api/auth/sign-in/email';
const _signUpPath = '/api/auth/sign-up/email';
const _mePath = '/api/me';
const _signOutPath = '/api/auth/sign-out';
const _tokenHeader = 'set-auth-token';

typedef AuthSession = ({String token, SessionUser user});

abstract class AuthRepository {
  Future<Result<AuthSession>> signIn(String email, String password);
  Future<Result<AuthSession>> signUp(
    String name,
    String email,
    String password,
  );
  Future<Result<SessionUser>> me();
  Future<Result<void>> signOut();
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._dio);

  final Dio _dio;

  @override
  Future<Result<AuthSession>> signIn(String email, String password) =>
      _guard(() async {
        final res = await _dio.post<Object?>(
          _signInPath,
          data: {'email': email.trim(), 'password': password},
        );
        return _readSession(res);
      });

  @override
  Future<Result<AuthSession>> signUp(
    String name,
    String email,
    String password,
  ) => _guard(() async {
    final res = await _dio.post<Object?>(
      _signUpPath,
      data: {'name': name.trim(), 'email': email.trim(), 'password': password},
    );
    return _readSession(res);
  });

  @override
  Future<Result<SessionUser>> me() => _guard(() async {
    final res = await _dio.get<Object?>(_mePath);
    return _readUser(res.data);
  });

  @override
  Future<Result<void>> signOut() => _guard(() async {
    await _dio.post<Object?>(_signOutPath, data: <String, Object>{});
  });

  Future<Result<T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Ok(await call());
    } on DioException catch (e) {
      final error = e.error;
      return Err(error is AppException ? error : mapDioException(e));
    } on AppException catch (e) {
      return Err(e);
    } catch (e, stack) {
      AppLogger.error('Auth call failed', error: e, stackTrace: stack);
      return Err(UnknownException('Auth call failed', cause: e));
    }
  }

  AuthSession _readSession(Response<Object?> res) {
    final body = res.data;
    final fromHeader = res.headers.value(_tokenHeader);
    final fromBody = body is Map<String, dynamic> ? body['token'] : null;
    final token = (fromHeader != null && fromHeader.isNotEmpty)
        ? fromHeader
        : (fromBody is String && fromBody.isNotEmpty ? fromBody : null);
    if (token == null) throw const UnknownException('Missing session token');
    return (token: token, user: _readUser(body));
  }

  SessionUser _readUser(Object? body) {
    final user = body is Map<String, dynamic> ? body['user'] : null;
    if (user is Map<String, dynamic>) {
      final id = user['id'], name = user['name'], email = user['email'];
      if (id is String &&
          id.isNotEmpty &&
          name is String &&
          name.isNotEmpty &&
          email is String &&
          email.isNotEmpty) {
        return SessionUser(id: id, name: name, email: email);
      }
    }
    throw const UnknownException('Malformed user payload');
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => ApiAuthRepository(ref.watch(dioProvider)),
);
