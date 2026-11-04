import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/error/result.dart';
import 'session_controller.dart';

/// Pragmatic format check, not RFC 5322: one `@`, a dot in the domain, no spaces.
final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
const minPasswordLength = 8;
const maxPasswordLength = 128;
const minNameLength = 2;
const maxNameLength = 100;
const _invalidCredentialsCode = 'INVALID_EMAIL_OR_PASSWORD';
const _userExistsCodePrefix = 'USER_ALREADY_EXISTS';

enum AuthMode { signIn, signUp }

enum AuthFormError {
  invalidInput,
  wrongCredentials,
  emailTaken,
  network,
  unknown,
}

class AuthFormState {
  const AuthFormState({
    this.mode = AuthMode.signIn,
    this.name = '',
    this.email = '',
    this.password = '',
    this.obscured = true,
    this.submitting = false,
    this.error,
  });

  final AuthMode mode;
  final String name, email, password;
  final bool obscured, submitting;
  final AuthFormError? error;

  AuthFormState copyWith({
    AuthMode? mode,
    String? name,
    String? email,
    String? password,
    bool? obscured,
    bool? submitting,
    AuthFormError? error,
    bool clearError = false,
  }) => AuthFormState(
    mode: mode ?? this.mode,
    name: name ?? this.name,
    email: email ?? this.email,
    password: password ?? this.password,
    obscured: obscured ?? this.obscured,
    submitting: submitting ?? this.submitting,
    error: clearError ? null : (error ?? this.error),
  );
}

class AuthFormViewModel extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  void setMode(AuthMode mode) {
    if (state.submitting) return;
    state = state.copyWith(
      mode: mode,
      name: '',
      password: '',
      clearError: true,
    );
  }

  void name(String v) => state = state.copyWith(name: v, clearError: true);
  void email(String v) => state = state.copyWith(email: v, clearError: true);
  void password(String v) =>
      state = state.copyWith(password: v, clearError: true);
  void toggleVisibility() => state = state.copyWith(obscured: !state.obscured);

  bool get _valid {
    final passwordOk =
        state.password.length >= minPasswordLength &&
        state.password.length <= maxPasswordLength;
    final nameLength = state.name.trim().length;
    final nameOk =
        state.mode == AuthMode.signIn ||
        (nameLength >= minNameLength && nameLength <= maxNameLength);
    return _emailPattern.hasMatch(state.email.trim()) && passwordOk && nameOk;
  }

  /// Returns true when the session was established.
  Future<bool> submit() async {
    if (state.submitting) return false;
    if (!_valid) {
      state = state.copyWith(error: AuthFormError.invalidInput);
      return false;
    }
    state = state.copyWith(submitting: true, clearError: true);
    final session = ref.read(sessionControllerProvider.notifier);
    final result = state.mode == AuthMode.signIn
        ? await session.signIn(state.email, state.password)
        : await session.signUp(state.name, state.email, state.password);
    // The screen (and this autoDispose notifier) may be gone if the user left
    // while the request was in flight; writing state then would throw.
    if (!ref.mounted) return false;
    switch (result) {
      case Ok():
        state = state.copyWith(submitting: false);
        return true;
      case Err(:final error):
        state = state.copyWith(submitting: false, error: _map(error));
        return false;
    }
  }

  AuthFormError _map(AppException e) => switch (e) {
    ApiException(errorCode: _invalidCredentialsCode) =>
      AuthFormError.wrongCredentials,
    ApiException(:final errorCode?)
        when errorCode.startsWith(_userExistsCodePrefix) =>
      AuthFormError.emailTaken,
    NetworkException() => AuthFormError.network,
    _ => AuthFormError.unknown,
  };
}

final authFormViewModelProvider =
    NotifierProvider.autoDispose<AuthFormViewModel, AuthFormState>(
      AuthFormViewModel.new,
    );
