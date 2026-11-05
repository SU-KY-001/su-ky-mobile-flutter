import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../auth/session_user.dart';
import '../error/app_exception.dart';
import '../logging/app_logger.dart';

const _tokenKey = 'auth.token';
const _userKey = 'auth.user';
const _storageTimeout = Duration(seconds: 10);

typedef StoredSession = ({String token, SessionUser user});

/// Bearer token and cached user in secure storage. [current] is a synchronous
/// cache so the HTTP interceptor never awaits storage on the request path.
class TokenStore {
  TokenStore(this._storage);

  final FlutterSecureStorage _storage;
  final _cleared = StreamController<void>.broadcast();
  String? _token;

  String? get current => _token;

  /// Fires after [clear] so session state can drop to guest.
  Stream<void> get onCleared => _cleared.stream;

  Future<StoredSession?> load() async {
    try {
      final token = await _storage
          .read(key: _tokenKey)
          .timeout(_storageTimeout);
      final raw = await _storage.read(key: _userKey).timeout(_storageTimeout);
      if (token == null || raw == null) return null;
      final user = _decodeUser(raw);
      if (token.isEmpty || user == null) {
        await _wipe();
        return null;
      }
      _token = token;
      return (token: token, user: user);
    } catch (error, stack) {
      AppLogger.error('Cannot read session', error: error, stackTrace: stack);
      return null;
    }
  }

  Future<void> save(String token, SessionUser user) async {
    try {
      await _storage
          .write(key: _tokenKey, value: token)
          .timeout(_storageTimeout);
      await _storage
          .write(key: _userKey, value: _encodeUser(user))
          .timeout(_storageTimeout);
      _token = token;
    } catch (error, stack) {
      AppLogger.error('Cannot save session', error: error, stackTrace: stack);
      throw StorageException('Cannot save session', cause: error);
    }
  }

  Future<void> clear() async {
    await _wipe();
    _cleared.add(null);
  }

  Future<void> _wipe() async {
    _token = null;
    try {
      await _storage.delete(key: _tokenKey).timeout(_storageTimeout);
      await _storage.delete(key: _userKey).timeout(_storageTimeout);
    } catch (error, stack) {
      AppLogger.error('Cannot clear session', error: error, stackTrace: stack);
    }
  }

  void dispose() => _cleared.close();

  static String _encodeUser(SessionUser u) =>
      jsonEncode({'id': u.id, 'name': u.name, 'email': u.email});

  static SessionUser? _decodeUser(String raw) {
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return null;
      final id = json['id'], name = json['name'], email = json['email'];
      if (id is String &&
          id.isNotEmpty &&
          name is String &&
          name.isNotEmpty &&
          email is String &&
          email.isNotEmpty) {
        return SessionUser(id: id, name: name, email: email);
      }
    } on FormatException {
      return null;
    }
    return null;
  }
}
