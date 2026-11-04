import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:su_ky_mobile/core/di/providers.dart';
import 'package:su_ky_mobile/core/error/app_exception.dart';
import 'package:su_ky_mobile/core/error/result.dart';
import 'package:su_ky_mobile/features/auth/data/auth_repository.dart';
import 'package:su_ky_mobile/features/auth/ui/auth_form_view_model.dart';
import 'package:su_ky_mobile/features/auth/ui/session_controller.dart';

import '../../support/stub_http.dart';

const _userJson = {
  'user': {'id': 'u1', 'name': 'Ann', 'email': 'a@b.co'},
};
const _signInOk = StubReply(
  200,
  _userJson,
  headers: {'set-auth-token': 'tok-1'},
);

ProviderContainer _container(StubHandler handler) {
  FlutterSecureStorage.setMockInitialValues({});
  final c = ProviderContainer(
    overrides: [
      appConfigProvider.overrideWithValue(testConfig),
      dioProvider.overrideWith((ref) {
        final (dio, _) = stubDio(
          handler,
          tokens: ref.watch(tokenStoreProvider),
        );
        return dio;
      }),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('ApiAuthRepository', () {
    test('sign-in takes the token from the set-auth-token header', () async {
      final (dio, adapter) = stubDio((_) => _signInOk);
      final result = await ApiAuthRepository(dio)
          .signIn(' a@b.co ', 'pw12345678');
      final session = (result as Ok<AuthSession>).value;
      expect(session.token, 'tok-1');
      expect(session.user.email, 'a@b.co');
      expect(adapter.requests.single.data, {
        'email': 'a@b.co',
        'password': 'pw12345678',
      });
    });

    test('falls back to a body token, and fails when there is none', () async {
      final (bodyDio, _) = stubDio(
        (_) => const StubReply(200, {..._userJson, 'token': 'body-tok'}),
      );
      final ok = await ApiAuthRepository(bodyDio).signIn('a@b.co', 'x');
      expect((ok as Ok<AuthSession>).value.token, 'body-tok');

      final (noTokDio, _) = stubDio((_) => const StubReply(200, _userJson));
      final err = await ApiAuthRepository(noTokDio).signIn('a@b.co', 'x');
      expect((err as Err<AuthSession>).error, isA<UnknownException>());
    });

    test('a malformed user payload is an error, not a crash', () async {
      final (dio, _) = stubDio(
        (_) => const StubReply(
          200,
          {
            'user': {'id': 'u1'},
          },
          headers: {'set-auth-token': 't'},
        ),
      );
      final r = await ApiAuthRepository(dio).signIn('a@b.co', 'x');
      expect((r as Err<AuthSession>).error, isA<UnknownException>());
    });

    test('wrong password maps to ApiException with the code', () async {
      final (dio, _) = stubDio(
        (_) => const StubReply(401, {'code': 'INVALID_EMAIL_OR_PASSWORD'}),
      );
      final r = await ApiAuthRepository(dio).signIn('a@b.co', 'bad');
      final e = (r as Err<AuthSession>).error as ApiException;
      expect(e.statusCode, 401);
      expect(e.errorCode, 'INVALID_EMAIL_OR_PASSWORD');
    });

    test('offline maps to a retryable NetworkException', () async {
      final (dio, _) = stubDio(
        (_) =>
            const StubReply(0, '', throwType: DioExceptionType.connectionError),
      );
      final r = await ApiAuthRepository(dio).me();
      expect((r as Err<dynamic>).error.isRetryable, isTrue);
    });
  });

  group('SessionController', () {
    test('hydrates as guest with empty storage', () async {
      final c = _container((_) => const StubReply(401, {}));
      c.read(sessionControllerProvider);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final s = c.read(sessionControllerProvider);
      expect(s.hydrated, isTrue);
      expect(s.isAuthenticated, isFalse);
    });

    test('sign-in stores the session, sign-out returns to guest', () async {
      final c = _container((o) {
        if (o.path.endsWith('sign-in/email')) return _signInOk;
        return const StubReply(200, {});
      });
      final session = c.read(sessionControllerProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(await session.signIn('a@b.co', 'pw12345678'), isA<Ok<void>>());
      expect(c.read(sessionControllerProvider).user?.name, 'Ann');
      expect(c.read(tokenStoreProvider).current, 'tok-1');

      await session.signOut();
      await Future<void>.delayed(Duration.zero);
      expect(c.read(sessionControllerProvider).isAuthenticated, isFalse);
      expect(c.read(tokenStoreProvider).current, isNull);
    });

    test(
      'sign-out clears the local session even if the request fails',
      () async {
        final c = _container((o) {
          if (o.path.endsWith('sign-in/email')) return _signInOk;
          return const StubReply(500, {});
        });
        final session = c.read(sessionControllerProvider.notifier);
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await session.signIn('a@b.co', 'pw12345678');
        expect(await session.signOut(), isA<Err<void>>());
        await Future<void>.delayed(Duration.zero);
        expect(c.read(sessionControllerProvider).isAuthenticated, isFalse);
      },
    );

    test('a second sign-out joins the request already running', () async {
      var calls = 0;
      final c = _container((o) async {
        if (o.path.endsWith('sign-out')) {
          calls++;
          await Future<void>.delayed(const Duration(milliseconds: 30));
        }
        return const StubReply(200, {});
      });
      final session = c.read(sessionControllerProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final first = session.signOut();
      final second = session.signOut();
      await Future.wait([first, second]);

      expect(calls, 1);
    });

    test('a stored session survives being offline at start-up', () async {
      FlutterSecureStorage.setMockInitialValues({
        'auth.token': 'tok-1',
        'auth.user': '{"id":"u1","name":"Ann","email":"a@b.co"}',
      });
      final c = ProviderContainer(
        overrides: [
          appConfigProvider.overrideWithValue(testConfig),
          dioProvider.overrideWith(
            (ref) => stubDio(
              (_) => const StubReply(
                0,
                '',
                throwType: DioExceptionType.connectionError,
              ),
              tokens: ref.watch(tokenStoreProvider),
            ).$1,
          ),
        ],
      );
      addTearDown(c.dispose);
      c.read(sessionControllerProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(c.read(sessionControllerProvider).isAuthenticated, isTrue);
    });

    test('a 401 on revalidation drops the stored session', () async {
      FlutterSecureStorage.setMockInitialValues({
        'auth.token': 'tok-1',
        'auth.user': '{"id":"u1","name":"Ann","email":"a@b.co"}',
      });
      final c = ProviderContainer(
        overrides: [
          appConfigProvider.overrideWithValue(testConfig),
          dioProvider.overrideWith(
            (ref) => stubDio(
              (_) => const StubReply(401, {}),
              tokens: ref.watch(tokenStoreProvider),
            ).$1,
          ),
        ],
      );
      addTearDown(c.dispose);
      c.read(sessionControllerProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(c.read(sessionControllerProvider).hydrated, isTrue);
      expect(c.read(sessionControllerProvider).isAuthenticated, isFalse);
    });
  });

  group('AuthFormViewModel', () {
    Future<AuthFormViewModel> setup(ProviderContainer c) async {
      c.listen(authFormViewModelProvider, (_, _) {});
      return c.read(authFormViewModelProvider.notifier);
    }

    test('rejects bad email, short password and short sign-up name', () async {
      final c = _container((_) => _signInOk);
      final vm = await setup(c);
      vm.email('nope');
      vm.password('x' * minPasswordLength);
      expect(await vm.submit(), isFalse);
      expect(
        c.read(authFormViewModelProvider).error,
        AuthFormError.invalidInput,
      );

      vm.email('a@b.co');
      vm.password('x' * (minPasswordLength - 1));
      expect(await vm.submit(), isFalse);

      vm.setMode(AuthMode.signUp);
      vm.password('x' * minPasswordLength);
      vm.name('A');
      expect(await vm.submit(), isFalse);
    });

    test(
      'wrong credentials map to a form error, then a valid retry works',
      () async {
        var attempts = 0;
        final c = _container((_) {
          attempts++;
          return attempts == 1
              ? const StubReply(401, {'code': 'INVALID_EMAIL_OR_PASSWORD'})
              : _signInOk;
        });
        final vm = await setup(c);
        vm.email('a@b.co');
        vm.password('wrong-password');
        expect(await vm.submit(), isFalse);
        expect(
          c.read(authFormViewModelProvider).error,
          AuthFormError.wrongCredentials,
        );
        expect(c.read(authFormViewModelProvider).submitting, isFalse);

        expect(await vm.submit(), isTrue);
      },
    );

    test('email-taken and offline errors are told apart', () async {
      final taken = _container(
        (_) => const StubReply(422, {
          'code': 'USER_ALREADY_EXISTS_USE_ANOTHER_EMAIL',
        }),
      );
      final vm = await setup(taken);
      vm.setMode(AuthMode.signUp);
      vm.name('Ann');
      vm.email('a@b.co');
      vm.password('pw12345678');
      expect(await vm.submit(), isFalse);
      expect(
        taken.read(authFormViewModelProvider).error,
        AuthFormError.emailTaken,
      );

      final offline = _container(
        (_) =>
            const StubReply(0, '', throwType: DioExceptionType.connectionError),
      );
      final vm2 = await setup(offline);
      vm2.email('a@b.co');
      vm2.password('pw12345678');
      expect(await vm2.submit(), isFalse);
      expect(
        offline.read(authFormViewModelProvider).error,
        AuthFormError.network,
      );
    });

    test('a second submit while one is running is ignored', () async {
      var calls = 0;
      final c = _container((o) async {
        if (o.path.endsWith('sign-in/email')) {
          calls++;
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return _signInOk;
        }
        return const StubReply(200, {});
      });
      final vm = await setup(c);
      vm.email('a@b.co');
      vm.password('pw12345678');
      final first = vm.submit();
      final second = await vm.submit();
      expect(second, isFalse);
      expect(await first, isTrue);
      expect(calls, 1);
    });
  });
}
