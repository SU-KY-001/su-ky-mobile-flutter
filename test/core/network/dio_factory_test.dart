import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:su_ky_mobile/core/auth/session_user.dart';
import 'package:su_ky_mobile/core/error/app_exception.dart';
import 'package:su_ky_mobile/core/network/dio_factory.dart';
import 'package:su_ky_mobile/core/storage/token_store.dart';

import '../../support/stub_http.dart';

DioException _bad(int status, [Object? data]) {
  final req = RequestOptions(path: '/x');
  return DioException(
    requestOptions: req,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: req, statusCode: status, data: data),
  );
}

const _user = SessionUser(id: 'u1', name: 'Ann', email: 'a@b.co');

Future<TokenStore> _signedInStore() async {
  FlutterSecureStorage.setMockInitialValues({});
  final store = TokenStore(const FlutterSecureStorage());
  await store.save('tok-1', _user);
  return store;
}

void main() {
  group('mapDioException', () {
    test('5xx and timeouts are retryable network errors', () {
      expect(mapDioException(_bad(503)), isA<NetworkException>());
      expect(mapDioException(_bad(503)).isRetryable, isTrue);
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.connectionError,
      ]) {
        final e = DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: type,
        );
        expect(mapDioException(e), isA<NetworkException>(), reason: '$type');
      }
    });

    test('4xx is a non-retryable ApiException carrying status and code', () {
      final e = mapDioException(
        _bad(400, {'error_code': 'BAD', 'message': 'no'}),
      ) as ApiException;
      expect(e.statusCode, 400);
      expect(e.errorCode, 'BAD');
      expect(e.message, 'no');
      expect(e.isRetryable, isFalse);
    });

    test('reads the auth-style {code} body and ignores a non-map body', () {
      expect(
        (mapDioException(
          _bad(401, {'code': 'INVALID_EMAIL_OR_PASSWORD'}),
        ) as ApiException).errorCode,
        'INVALID_EMAIL_OR_PASSWORD',
      );
      final plain = mapDioException(_bad(404, 'oops')) as ApiException;
      expect(plain.errorCode, isNull);
    });

    test('a retryable API code makes a 4xx retryable', () {
      expect(
        mapDioException(_bad(429, {'error_code': 'RATE_LIMITED'})).isRetryable,
        isTrue,
      );
    });

    test('cancel is unknown and not retryable', () {
      final e = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.cancel,
      );
      expect(mapDioException(e), isA<UnknownException>());
    });
  });

  group('createDio + AuthInterceptor', () {
    test('adds the Bearer token when signed in, none for a guest', () async {
      final store = await _signedInStore();
      final (dio, adapter) = stubDio(
        (_) => const StubReply(200, {}),
        tokens: store,
      );
      await dio.get<Object?>('/api/me');
      expect(adapter.requests.single.headers['Authorization'], 'Bearer tok-1');

      final (guest, guestAdapter) = stubDio((_) => const StubReply(200, {}));
      await guest.get<Object?>('/api/series');
      expect(
        guestAdapter.requests.single.headers.containsKey('Authorization'),
        isFalse,
      );
    });

    test('401 on a Bearer call clears the stored session', () async {
      final store = await _signedInStore();
      var cleared = 0;
      store.onCleared.listen((_) => cleared++);
      final (dio, _) = stubDio((_) => const StubReply(401, {}), tokens: store);
      await expectLater(
        dio.get<Object?>('/api/me'),
        throwsA(isA<DioException>()),
      );
      await Future<void>.delayed(Duration.zero);
      expect(store.current, isNull);
      expect(cleared, 1);
    });

    test('401 from sign-in (wrong password) keeps the session', () async {
      final store = await _signedInStore();
      final (dio, _) = stubDio(
        (_) => const StubReply(401, {'code': 'INVALID_EMAIL_OR_PASSWORD'}),
        tokens: store,
      );
      await expectLater(
        dio.post<Object?>('/api/auth/sign-in/email', data: {}),
        throwsA(
          isA<DioException>().having(
            (e) => e.error,
            'error',
            isA<ApiException>(),
          ),
        ),
      );
      expect(store.current, 'tok-1');
    });

    test(
      'a failed call surfaces an AppException in DioException.error',
      () async {
        final (dio, _) = stubDio((_) => const StubReply(500, {}));
        await expectLater(
          dio.get<Object?>('/x'),
          throwsA(
            isA<DioException>().having(
              (e) => e.error,
              'error',
              isA<NetworkException>(),
            ),
          ),
        );
      },
    );
  });
}
