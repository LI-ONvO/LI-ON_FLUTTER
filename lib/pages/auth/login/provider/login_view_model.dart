import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/utils/validators.dart';

class LoginState {
  final String email;
  final String password;
  final AutovalidateMode autovalidateMode;

  const LoginState({
    this.email = '',
    this.password = '',
    this.autovalidateMode = AutovalidateMode.disabled,
  });

  bool get isFilled =>
      email.length >= Validators.minEmailLength &&
      password.length >= Validators.minPasswordLength;

  LoginState copyWith({
    String? email,
    String? password,
    AutovalidateMode? autovalidateMode,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
    );
  }
}

class LoginViewModel extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  void setEmail(String value) => state = state.copyWith(email: value);

  void setPassword(String value) => state = state.copyWith(password: value);

  void markSubmitted() {
    state = state.copyWith(
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}

final loginViewModelProvider = NotifierProvider<LoginViewModel, LoginState>(
  LoginViewModel.new,
);
