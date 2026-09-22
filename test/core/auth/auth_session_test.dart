import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/core/auth/auth_user.dart';
import 'package:li_on/core/auth/auth_session.dart';

void main() {
  const user = AuthUser(
    userId: 1,
    email: 'user@example.com',
    nickname: '테스트 사용자',
  );

  test('세션 복원 시 로그인 사용자 정보를 유지한다', () {
    final session = AuthSessionController();
    addTearDown(session.dispose);

    session.restore(user);

    expect(session.isAuthenticated, isTrue);
    expect(session.user, user);
  });

  test('온보딩은 회원가입 완료 상태에서만 허용한다', () {
    final session = AuthSessionController();
    addTearDown(session.dispose);

    expect(session.canAccessOnboarding, isFalse);
    session.startOnboarding();
    expect(session.canAccessOnboarding, isTrue);
    session.finishOnboarding();
    expect(session.canAccessOnboarding, isFalse);
  });

  test('로그아웃 시 세션과 온보딩 접근 권한을 초기화한다', () {
    final session = AuthSessionController();
    addTearDown(session.dispose);
    session.restore(user);
    session.startOnboarding();

    session.signOut();

    expect(session.isAuthenticated, isFalse);
    expect(session.user, isNull);
    expect(session.canAccessOnboarding, isFalse);
  });
}
