import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/pages/auth/model/email_verification.dart';
import 'package:li_on/pages/auth/model/login_result.dart';
import 'package:li_on/pages/auth/model/sign_up_result.dart';
import 'package:li_on/pages/auth/provider/auth_repository.dart';
import 'package:li_on/pages/auth/sign_up/view/sign_up_page.dart';

import '../../../../support/widget_test_helpers.dart';

/// 실제 서버 없이 테스트할 수 있도록, 인증코드 발송만 성공으로 응답하는
/// 가짜 리포지토리. 이 화면에서 다른 메서드는 쓰지 않는다.
class _FakeAuthRepository implements AuthRepository {
  const _FakeAuthRepository();

  @override
  Future<void> logout() async {}

  @override
  Future<EmailSendCodeResult> sendEmailVerificationCode({
    required String email,
  }) async {
    return EmailSendCodeResult(email: email, expiresIn: 180);
  }

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String passwordConfirm,
    required String nickname,
  }) => throw UnimplementedError();

  @override
  Future<EmailVerifyCodeResult> verifyEmailCode({
    required String email,
    required String code,
  }) => throw UnimplementedError();

  @override
  Future<EmailCheckResult> checkEmail({required String email}) =>
      throw UnimplementedError();
}

Finder _fieldInput(Key fieldKey) {
  return find.descendant(
    of: find.byKey(fieldKey),
    matching: find.byType(TextFormField),
  );
}

void main() {
  Future<void> pumpSignUpPage(WidgetTester tester) async {
    // _submit()이 성공하면 GoRouter로 다음 화면을 미는데(context.push), 그
    // 라우터가 없으면 테스트가 터지므로 최소한의 라우터를 같이 띄운다.
    final GoRouter router = GoRouter(
      initialLocation: '/sign-up',
      routes: [
        GoRoute(
          path: '/sign-up',
          builder: (context, state) => const SignUpPage(),
        ),
        GoRoute(
          path: '/sign-up/verify-email',
          builder: (context, state) => const SizedBox(),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(const _FakeAuthRepository()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
  }

  Future<void> fillAllFields(
    WidgetTester tester, {
    String email = 'user@example.com',
    String nickname = '홍길동',
    String password = 'abc12345!',
    String passwordConfirm = 'abc12345!',
  }) async {
    await tester.enterText(_fieldInput(const Key('emailField')), email);
    await tester.enterText(_fieldInput(const Key('nicknameField')), nickname);
    await tester.enterText(_fieldInput(const Key('passwordField')), password);
    await tester.enterText(
      _fieldInput(const Key('passwordConfirmField')),
      passwordConfirm,
    );
    await tester.pump();
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.tap(find.text('메일 인증 받기'));
    await tester.pump();
  }

  group('버튼 활성화 (최소 글자 수 기준)', () {
    testWidgets('처음에는 비활성화 상태다', (tester) async {
      await pumpSignUpPage(tester);

      expect(isElevatedButtonEnabled(tester), isFalse);
    });

    testWidgets('일부 필드만 채우면 비활성화 상태를 유지한다', (tester) async {
      await pumpSignUpPage(tester);

      await tester.enterText(
        _fieldInput(const Key('emailField')),
        'user@example.com',
      );
      await tester.pump();

      expect(isElevatedButtonEnabled(tester), isFalse);
    });

    testWidgets('최소 글자 수를 채우지 못하면 비활성화 상태를 유지한다', (tester) async {
      await pumpSignUpPage(tester);

      await fillAllFields(
        tester,
        email: 'a@b.c', // 5자, 최소 6자 미달
        nickname: '나', // 1자, 최소 2자 미달
        password: 'short12', // 7자, 최소 8자 미달
        passwordConfirm: 'short12',
      );

      expect(isElevatedButtonEnabled(tester), isFalse);
    });

    testWidgets('최소 글자 수를 채우면 형식이 틀려도 활성화된다', (tester) async {
      await pumpSignUpPage(tester);

      await fillAllFields(
        tester,
        email: 'notanemail',
        password: 'allletters',
        passwordConfirm: 'allletters',
      );

      expect(isElevatedButtonEnabled(tester), isTrue);
    });

    testWidgets('채운 뒤 한 필드를 다시 비우면 비활성화된다', (tester) async {
      await pumpSignUpPage(tester);
      await fillAllFields(tester);
      expect(isElevatedButtonEnabled(tester), isTrue);

      await tester.enterText(_fieldInput(const Key('emailField')), '');
      await tester.pump();

      expect(isElevatedButtonEnabled(tester), isFalse);
    });
  });

  group('버튼을 누르기 전', () {
    testWidgets('형식이 잘못된 값을 입력해도 에러 메시지를 보여주지 않는다', (tester) async {
      await pumpSignUpPage(tester);

      await tester.enterText(
        _fieldInput(const Key('emailField')),
        'notanemail',
      );
      await tester.pump();

      expect(find.text('올바른 이메일 형식이 아닙니다'), findsNothing);
    });
  });

  group('버튼을 누른 뒤', () {
    testWidgets('형식이 잘못된 값이 있으면 에러 메시지를 보여주고 실패 스낵바를 띄운다', (tester) async {
      await pumpSignUpPage(tester);

      await fillAllFields(
        tester,
        email: 'notanemail',
        password: 'allletters',
        passwordConfirm: 'differentvalue',
      );
      await submit(tester);

      expect(find.text('올바른 이메일 형식이 아닙니다'), findsOneWidget);
      expect(find.text('영문, 숫자, 특수문자를 포함해 8자 이상 입력해주세요'), findsOneWidget);
      expect(find.text('비밀번호가 일치하지 않습니다'), findsOneWidget);
      expect(find.text('입력 내용을 다시 확인해주세요'), findsOneWidget);
    });

    testWidgets('모든 값이 유효하면 성공 스낵바를 보여준다', (tester) async {
      await pumpSignUpPage(tester);

      await fillAllFields(tester);
      await submit(tester);
      await tester.pump();

      expect(find.text('인증 메일을 보냈습니다'), findsOneWidget);
    });

    testWidgets('그 다음부터는 입력하는 대로 실시간으로 에러가 갱신된다', (tester) async {
      await pumpSignUpPage(tester);

      await fillAllFields(tester, email: 'notanemail');
      await submit(tester);
      expect(find.text('올바른 이메일 형식이 아닙니다'), findsOneWidget);

      await tester.enterText(
        _fieldInput(const Key('emailField')),
        'user@example.com',
      );
      await tester.pump();

      expect(find.text('올바른 이메일 형식이 아닙니다'), findsNothing);
    });
  });

  group('이메일 검증', () {
    testWidgets('최상위 도메인이 한 글자면 에러 메시지를 보여준다', (tester) async {
      await pumpSignUpPage(tester);

      await fillAllFields(tester, email: 'choi0250655@gmail.c');
      await submit(tester);

      expect(find.text('올바른 이메일 형식이 아닙니다'), findsOneWidget);
    });

    testWidgets('올바른 형식이면 에러 메시지를 보여주지 않는다', (tester) async {
      await pumpSignUpPage(tester);

      await fillAllFields(tester);
      await submit(tester);
      await tester.pump();

      expect(find.text('올바른 이메일 형식이 아닙니다'), findsNothing);
    });
  });
}
