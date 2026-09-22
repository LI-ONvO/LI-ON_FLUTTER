import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/network/token_storage.dart';
import 'package:li_on/core/utils/validators.dart';
import 'package:li_on/features/auth/data/login_result.dart';
import 'package:li_on/features/auth/data/auth_repository.dart';
import 'package:li_on/core/auth/auth_session.dart';

class LoginState {
  final String email;
  final String password;
  final AutovalidateMode autovalidateMode;

  /// 로그인 요청이 진행 중인지. 버튼을 비활성화해 중복 제출을 막는다.
  final bool isSubmitting;

  const LoginState({
    this.email = '',
    this.password = '',
    this.autovalidateMode = AutovalidateMode.disabled,
    this.isSubmitting = false,
  });

  bool get isFilled =>
      email.length >= Validators.minEmailLength &&
      password.length >= Validators.minPasswordLength;

  LoginState copyWith({
    String? email,
    String? password,
    AutovalidateMode? autovalidateMode,
    bool? isSubmitting,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
      isSubmitting: isSubmitting ?? this.isSubmitting,
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

  Future<void> login() async {
    if (state.isSubmitting) return;
    state = state.copyWith(isSubmitting: true);
    try {
      final LoginResult result = await ref
          .read(authRepositoryProvider)
          .login(email: state.email, password: state.password);

      await ref
          .read(tokenStorageProvider)
          .saveTokens(
            accessToken: result.accessToken,
            refreshToken: result.refreshToken,
          );
      await ref.read(tokenStorageProvider).saveUser(result.user);
      ref.read(authSessionProvider).signIn(result.user);
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  /// 로그아웃 등으로 로그인 화면에 다시 왔을 때 이전 입력값이 남지 않게 한다.
  void reset() {
    state = const LoginState();
  }
}

final loginViewModelProvider = NotifierProvider<LoginViewModel, LoginState>(
  LoginViewModel.new,
);
