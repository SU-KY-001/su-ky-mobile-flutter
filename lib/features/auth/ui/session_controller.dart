import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session_user.dart';
import '../../../core/di/providers.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/result.dart';
import '../../../core/logging/app_logger.dart';
import '../data/auth_repository.dart';

class SessionState {
  const SessionState({this.hydrated = false, this.user});

  final bool hydrated;
  final SessionUser? user;

  bool get isAuthenticated => user != null;
}

/// App-wide session. Not autoDispose: it must outlive every screen.
class SessionController extends Notifier<SessionState> {
  /// A second tap on Sign out joins the request already running.
  Future<Result<void>>? _signOutInFlight;

  @override
  SessionState build() {
    final tokens = ref.read(tokenStoreProvider);
    final sub = tokens.onCleared.listen(
      (_) => state = SessionState(hydrated: state.hydrated),
    );
    ref.onDispose(sub.cancel);
    Future.microtask(hydrate);
    return const SessionState();
  }

  /// Restores the stored session, then revalidates it. Only a 401 (handled by
  /// the interceptor) signs out; being offline keeps the cached session.
  Future<void> hydrate() async {
    final tokens = ref.read(tokenStoreProvider);
    final stored = await tokens.load();
    if (stored == null) {
      state = const SessionState(hydrated: true);
      AppLogger.info('Session hydrated: guest');
      return;
    }
    state = SessionState(hydrated: true, user: stored.user);
    switch (await ref.read(authRepositoryProvider).me()) {
      case Ok(:final value):
        if (tokens.current == stored.token) {
          await _persist(stored.token, value);
        }
      case Err(:final error):
        AppLogger.info('Session revalidation skipped: ${error.runtimeType}');
    }
    AppLogger.info(
      'Session hydrated: ${state.isAuthenticated ? 'authenticated' : 'guest'}',
    );
  }

  Future<Result<void>> signIn(String email, String password) async =>
      _establish(
        await ref.read(authRepositoryProvider).signIn(email, password),
      );

  Future<Result<void>> signUp(
    String name,
    String email,
    String password,
  ) async => _establish(
    await ref.read(authRepositoryProvider).signUp(name, email, password),
  );

  Future<Result<void>> updateName(String name) async {
    final repo = ref.read(authRepositoryProvider);
    final trimmed = name.trim();
    if (trimmed.isEmpty) return const Err(UnknownException('Empty name'));
    if (trimmed == state.user?.name) return const Ok(null);
    switch (await repo.updateName(trimmed)) {
      case Err(:final error):
        return Err(error);
      case Ok():
        final token = ref.read(tokenStoreProvider).current;
        if (token == null) return const Ok(null);
        switch (await repo.me()) {
          case Ok(:final value):
            await _persist(token, value);
          case Err(:final error):
            AppLogger.error('Profile refresh failed', error: error);
        }
        return const Ok(null);
    }
  }

  Future<Result<void>> signOut() => _signOutInFlight ??= _runSignOut();

  Future<Result<void>> _runSignOut() async {
    try {
      final result = await ref.read(authRepositoryProvider).signOut();
      if (result case Err(:final error)) {
        AppLogger.error('Sign-out request failed', error: error);
      }
      await ref.read(tokenStoreProvider).clear();
      return result;
    } finally {
      _signOutInFlight = null;
    }
  }

  Future<Result<void>> _establish(Result<AuthSession> result) async {
    switch (result) {
      case Err(:final error):
        return Err(error);
      case Ok(:final value):
        try {
          await _persist(value.token, value.user);
        } on Exception catch (e) {
          return Err(e is AppException ? e : UnknownException('$e', cause: e));
        }
        return const Ok(null);
    }
  }

  Future<void> _persist(String token, SessionUser user) async {
    await ref.read(tokenStoreProvider).save(token, user);
    state = SessionState(hydrated: true, user: user);
  }
}

final sessionControllerProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);
