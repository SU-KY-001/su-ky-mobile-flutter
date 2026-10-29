import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginState {
  const LoginState({
    this.email = '',
    this.password = '',
    this.obscured = true,
    this.invalid = false,
  });
  final String email, password;
  final bool obscured, invalid;
  LoginState copyWith({
    String? email,
    String? password,
    bool? obscured,
    bool? invalid,
  }) => LoginState(
    email: email ?? this.email,
    password: password ?? this.password,
    obscured: obscured ?? this.obscured,
    invalid: invalid ?? this.invalid,
  );
}

class LoginViewModel extends Notifier<AsyncValue<LoginState>> {
  @override
  AsyncValue<LoginState> build() => const AsyncData(LoginState());
  void email(String value) => state = AsyncData(
    state.requireValue.copyWith(email: value, invalid: false),
  );
  void password(String value) => state = AsyncData(
    state.requireValue.copyWith(password: value, invalid: false),
  );
  void toggleVisibility() => state = AsyncData(
    state.requireValue.copyWith(obscured: !state.requireValue.obscured),
  );
  bool submit() {
    final form = state.requireValue;
    final valid =
        RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(form.email.trim()) &&
        form.password.length >= 6;
    state = AsyncData(form.copyWith(invalid: !valid));
    return valid;
  }
}

final loginViewModelProvider =
    NotifierProvider.autoDispose<LoginViewModel, AsyncValue<LoginState>>(
      LoginViewModel.new,
    );
