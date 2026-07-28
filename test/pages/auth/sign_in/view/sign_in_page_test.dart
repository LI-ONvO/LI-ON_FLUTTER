import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/pages/auth/sign_in/view/sign_in_page.dart';

import '../../../../support/widget_test_helpers.dart';

Finder _fieldInput(Key fieldKey) {
  return find.descendant(
    of: find.byKey(fieldKey),
    matching: find.byType(TextFormField),
  );
}

void main() {
  Future<void> pumpSignInPage(WidgetTester tester) =>
      pumpApp(tester, const SignInPage());

  Future<void> fillAllFields(
    WidgetTester tester, {
    String email = 'user@example.com',
    String password = 'abc12345',
    String passwordConfirm = 'abc12345',
    String verificationCode = '123456',
  }) async {
    await tester.enterText(_fieldInput(const Key('emailField')), email);
    await tester.enterText(_fieldInput(const Key('passwordField')), password);
    await tester.enterText(
      _fieldInput(const Key('passwordConfirmField')),
      passwordConfirm,
    );
    await tester.enterText(
      _fieldInput(const Key('verificationCodeField')),
      verificationCode,
    );
    await tester.pump();
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.tap(find.text('메일 인증 받기'));
    await tester.pump();
  }

  group('버튼 활성화 (최소 글자 수 기준)', () {
    testWidgets('처음에는 비활성화 상태다', (tester) async {
      await pumpSignInPage(tester);

      expect(isElevatedButtonEnabled(tester), isFalse);
    });

    testWidgets('일부 필드만 채우면 비활성화 상태를 유지한다', (tester) async {
      await pumpSignInPage(tester);

      await tester.enterText(
        _fieldInput(const Key('emailField')),
        'user@example.com',
      );
      await tester.pump();

      expect(isElevatedButtonEnabled(tester), isFalse);
    });

    testWidgets('최소 글자 수를 채우지 못하면 비활성화 상태를 유지한다', (tester) async {
      await pumpSignInPage(tester);

      await fillAllFields(
        tester,
        email: 'a@b.c', // 5자, 최소 6자 미달
        password: 'short12', // 7자, 최소 8자 미달
        passwordConfirm: 'short12',
        verificationCode: '12345', // 5자, 최소 6자 미달
      );

      expect(isElevatedButtonEnabled(tester), isFalse);
    });

    testWidgets('최소 글자 수를 채우면 형식이 틀려도 활성화된다', (tester) async {
      await pumpSignInPage(tester);

      await fillAllFields(
        tester,
        email: 'notanemail',
        password: 'allletters',
        passwordConfirm: 'differentvalue',
        verificationCode: 'abcdef',
      );

      expect(isElevatedButtonEnabled(tester), isTrue);
    });

    testWidgets('채운 뒤 한 필드를 다시 비우면 비활성화된다', (tester) async {
      await pumpSignInPage(tester);
      await fillAllFields(tester);
      expect(isElevatedButtonEnabled(tester), isTrue);

      await tester.enterText(_fieldInput(const Key('emailField')), '');
      await tester.pump();

      expect(isElevatedButtonEnabled(tester), isFalse);
    });
  });

  group('버튼을 누르기 전', () {
    testWidgets('형식이 잘못된 값을 입력해도 에러 메시지를 보여주지 않는다', (tester) async {
      await pumpSignInPage(tester);

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
      await pumpSignInPage(tester);

      await fillAllFields(
        tester,
        email: 'notanemail',
        password: 'allletters',
        passwordConfirm: 'differentvalue',
        verificationCode: 'abcdef',
      );
      await submit(tester);

      expect(find.text('올바른 이메일 형식이 아닙니다'), findsOneWidget);
      expect(find.text('영문, 숫자를 포함해 8자 이상 입력해주세요'), findsOneWidget);
      expect(find.text('비밀번호가 일치하지 않습니다'), findsOneWidget);
      expect(find.text('6자리 숫자를 입력해주세요'), findsOneWidget);
      expect(find.text('입력 내용을 다시 확인해주세요'), findsOneWidget);
    });

    testWidgets('모든 값이 유효하면 성공 스낵바를 보여준다', (tester) async {
      await pumpSignInPage(tester);

      await fillAllFields(tester);
      await submit(tester);

      expect(find.text('인증 메일을 보냈습니다'), findsOneWidget);
    });

    testWidgets('그 다음부터는 입력하는 대로 실시간으로 에러가 갱신된다', (tester) async {
      await pumpSignInPage(tester);

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
      await pumpSignInPage(tester);

      await fillAllFields(tester, email: 'choi0250655@gmail.c');
      await submit(tester);

      expect(find.text('올바른 이메일 형식이 아닙니다'), findsOneWidget);
    });

    testWidgets('올바른 형식이면 에러 메시지를 보여주지 않는다', (tester) async {
      await pumpSignInPage(tester);

      await fillAllFields(tester);
      await submit(tester);

      expect(find.text('올바른 이메일 형식이 아닙니다'), findsNothing);
    });
  });
}
