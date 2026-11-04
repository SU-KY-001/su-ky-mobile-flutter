import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:su_ky_mobile/core/auth/session_user.dart';
import 'package:su_ky_mobile/core/storage/token_store.dart';

const _user = SessionUser(id: 'u1', name: 'Ann', email: 'a@b.co');

TokenStore _store([Map<String, String> initial = const {}]) {
  FlutterSecureStorage.setMockInitialValues({...initial});
  return TokenStore(const FlutterSecureStorage());
}

void main() {
  test('save then load round-trips token and user', () async {
    final store = _store();
    await store.save('tok', _user);
    expect(store.current, 'tok');

    final fresh = TokenStore(const FlutterSecureStorage());
    final loaded = await fresh.load();
    expect(loaded?.token, 'tok');
    expect(loaded?.user, _user);
    expect(fresh.current, 'tok');
  });

  test('empty storage loads as a guest', () async {
    final store = _store();
    expect(await store.load(), isNull);
    expect(store.current, isNull);
  });

  test('a corrupt stored user wipes the session', () async {
    final store = _store({'auth.token': 'tok', 'auth.user': '{not json'});
    expect(await store.load(), isNull);
    expect(store.current, isNull);
    expect(await const FlutterSecureStorage().read(key: 'auth.token'), isNull);
  });

  test('a stored user with a missing field is rejected', () async {
    final store = _store({
      'auth.token': 'tok',
      'auth.user': '{"id":"u1","name":"","email":"a@b.co"}',
    });
    expect(await store.load(), isNull);
  });

  test('clear removes data and notifies once', () async {
    final store = _store();
    await store.save('tok', _user);
    var events = 0;
    store.onCleared.listen((_) => events++);
    await store.clear();
    await Future<void>.delayed(Duration.zero);
    expect(store.current, isNull);
    expect(events, 1);
    expect(await const FlutterSecureStorage().read(key: 'auth.user'), isNull);
  });
}
