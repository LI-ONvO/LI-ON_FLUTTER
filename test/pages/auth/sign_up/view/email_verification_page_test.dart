import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/pages/auth/model/email_verification.dart';
import 'package:li_on/pages/auth/model/login_result.dart';
import 'package:li_on/pages/auth/model/sign_up_result.dart';
import 'package:li_on/pages/auth/provider/auth_repository.dart';
import 'package:li_on/pages/auth/sign_up/provider/sign_in_view_model.dart';
import 'package:li_on/pages/auth/sign_up/view/email_verification_page.dart';

class _VerificationAuthRepository implements AuthRepository {
  _VerificationAuthRepository({required this.verified});

  final bool verified;
  int signUpCalls = 0;
  String? receivedVerificationToken;

  @override
  Future<void> logout() async {}

  @override
  Future<EmailVerifyCodeResult> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    return EmailVerifyCodeResult(
      email: email,
      verified: verified,
      verificationToken: verified ? 'verified-token' : '',
    );
  }

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String passwordConfirm,
    required String nickname,
    required String verificationToken,
  }) async {
    signUpCalls += 1;
    receivedVerificationToken = verificationToken;
    return SignUpResult(
      userId: 1,
      email: email,
      nickname: nickname,
      createdAt: DateTime(2026),
    );
  }

  @override
  Future<EmailSendCodeResult> sendEmailVerificationCode({
    required String email,
  }) => throw UnimplementedError();

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<EmailCheckResult> checkEmail({required String email}) =>
      throw UnimplementedError();
}

class _PrepopulatedSignInViewModel extends SignInViewModel {
  @override
  SignInState build() => const SignInState(
    email: 'user@example.com',
    password: 'abc12345',
    passwordConfirm: 'abc12345',
    nickname: '홍길동',
  );
}

void main() {
  Future<void> pumpPage(
    WidgetTester tester,
    _VerificationAuthRepository repository,
  ) async {
    final router = GoRouter(
      initialLocation: '/sign-up/verify-email',
      routes: [
        GoRoute(
          path: '/sign-up/verify-email',
          builder: (context, state) => const EmailVerificationPage(),
        ),
        GoRoute(path: '/login', builder: (context, state) => const SizedBox()),
        GoRoute(
          path: '/sign-up',
          builder: (context, state) => const SizedBox(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
          signInViewModelProvider.overrideWith(
            _PrepopulatedSignInViewModel.new,
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
  }

  Future<void> submitCode(WidgetTester tester) async {
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('verificationCodeField')),
        matching: find.byType(TextFormField),
      ),
      '123456',
    );
    await tester.pump();
    await tester.tap(find.text('가입 완료'));
    await tester.pump();
    await tester.pump();
  }

  testWidgets('인증 토큰을 회원가입 요청에 전달한다', (tester) async {
    final repository = _VerificationAuthRepository(verified: true);
    await pumpPage(tester, repository);

    await submitCode(tester);

    expect(repository.signUpCalls, 1);
    expect(repository.receivedVerificationToken, 'verified-token');
  });

  testWidgets('이메일 인증 실패 시 회원가입을 요청하지 않는다', (tester) async {
    final repository = _VerificationAuthRepository(verified: false);
    await pumpPage(tester, repository);

    await submitCode(tester);

    expect(repository.signUpCalls, 0);
    expect(find.text('인증 코드가 올바르지 않아요'), findsOneWidget);
  });
}
