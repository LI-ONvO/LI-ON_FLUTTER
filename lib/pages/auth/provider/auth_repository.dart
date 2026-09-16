import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/network/api_client.dart';
import 'package:li_on/core/network/api_exception.dart';
import 'package:li_on/pages/auth/model/email_verification.dart';
import 'package:li_on/pages/auth/model/login_result.dart';
import 'package:li_on/pages/auth/model/sign_up_result.dart';

abstract class AuthRepository {
  Future<LoginResult> login({required String email, required String password});

  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String passwordConfirm,
    required String nickname,
  });

  Future<EmailSendCodeResult> sendEmailVerificationCode({
    required String email,
  });

  Future<EmailVerifyCodeResult> verifyEmailCode({
    required String email,
    required String code,
  });

  Future<EmailCheckResult> checkEmail({required String email});

  /// `POST /api/auth/logout` — 서버의 refreshToken을 무효화한다.
  Future<void> logout();
}

class HttpAuthRepository implements AuthRepository {
  HttpAuthRepository(this.apiClient);

  final ApiClient apiClient;

  @override
  Future<LoginResult> login({required String email, required String password}) {
    return guardApiCall(() async {
      final response = await apiClient.dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );
      return LoginResult.fromJson(response.data);
    });
  }

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String passwordConfirm,
    required String nickname,
  }) {
    return guardApiCall(() async {
      final response = await apiClient.dio.post(
        '/api/auth/signup',
        data: {
          'email': email,
          'password': password,
          'passwordConfirm': passwordConfirm,
          'nickname': nickname,
        },
      );
      return SignUpResult.fromJson(response.data);
    });
  }

  @override
  Future<EmailSendCodeResult> sendEmailVerificationCode({
    required String email,
  }) {
    return guardApiCall(() async {
      final response = await apiClient.dio.post(
        '/api/auth/email/send-code',
        data: {'email': email},
      );
      return EmailSendCodeResult.fromJson(response.data);
    });
  }

  @override
  Future<EmailVerifyCodeResult> verifyEmailCode({
    required String email,
    required String code,
  }) {
    return guardApiCall(() async {
      final response = await apiClient.dio.post(
        '/api/auth/email/verify-code',
        data: {'email': email, 'code': code},
      );
      return EmailVerifyCodeResult.fromJson(response.data);
    });
  }

  @override
  Future<EmailCheckResult> checkEmail({required String email}) {
    return guardApiCall(() async {
      final response = await apiClient.dio.get(
        '/api/auth/check-email',
        queryParameters: {'email': email},
      );
      return EmailCheckResult.fromJson(response.data);
    });
  }

  @override
  Future<void> logout() {
    return guardApiCall(() async {
      await apiClient.dio.post('/api/auth/logout');
    });
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return HttpAuthRepository(ref.watch(apiClientProvider));
});
