import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/features/auth/presentation/pages/login_page.dart';
import 'package:li_on/features/auth/presentation/pages/sign_up_page.dart';

Finder _fieldInput(Key fieldKey) {
  return find.descendant(
    of: find.byKey(fieldKey),
    matching: find.byType(TextFormField),
  );
}

void main() {
  Future<void> pumpLoginPage(WidgetTester tester) async {
    final GoRouter router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        GoRoute(
          path: '/sign-up',
          builder: (context, state) => const SignUpPage(),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
  }

  testWidgets('회원가입으로 이동하면 로그인 입력값을 초기화한다', (tester) async {
    await pumpLoginPage(tester);
    await tester.enterText(
      _fieldInput(const Key('emailField')),
      'user@example.com',
    );
    await tester.enterText(_fieldInput(const Key('passwordField')), 'abc12345');
    await tester.pump();

    await tester.tap(find.text('회원가입'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();

    final TextFormField email = tester.widget(
      _fieldInput(const Key('emailField')),
    );
    final TextFormField password = tester.widget(
      _fieldInput(const Key('passwordField')),
    );
    expect(email.controller!.text, isEmpty);
    expect(password.controller!.text, isEmpty);
  });
}
