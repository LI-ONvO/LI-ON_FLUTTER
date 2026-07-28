import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/utils/validators.dart';

class SignInState {
  final String email;
  final String password;
  final String passwordConfirm;
  final String verificationCode;
  final AutovalidateMode autovalidateMode;

  const SignInState({
    this.email = '',
    this.password = '',
    this.passwordConfirm = '',
    this.verificationCode = '',
    this.autovalidateMode = AutovalidateMode.disabled,
  });

  bool get isFilled =>
      email.length >= Validators.minEmailLength &&
      password.length >= Validators.minPasswordLength &&
      passwordConfirm.length >= Validators.minPasswordLength &&
      verificationCode.length >= Validators.verificationCodeLength;

  SignInState copyWith({
    String? email,
    String? password,
    String? passwordConfirm,
    String? verificationCode,
    AutovalidateMode? autovalidateMode,
  }) {
    return SignInState(
      email: email ?? this.email,
      password: password ?? this.password,
      passwordConfirm: passwordConfirm ?? this.passwordConfirm,
      verificationCode: verificationCode ?? this.verificationCode,
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
    );
  }
}

class SignInViewModel extends Notifier<SignInState> {
  @override
  SignInState build() => const SignInState();

  void setEmail(String value) => state = state.copyWith(email: value);

  void setPassword(String value) => state = state.copyWith(password: value);

  void setPasswordConfirm(String value) =>
      state = state.copyWith(passwordConfirm: value);

  void setVerificationCode(String value) =>
      state = state.copyWith(verificationCode: value);

  void markSubmitted() {
    state = state.copyWith(autovalidateMode: AutovalidateMode.onUserInteraction);
  }
}

final signInViewModelProvider =
    NotifierProvider<SignInViewModel, SignInState>(SignInViewModel.new);
