import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/core/auth/auth_user.dart';
import 'package:li_on/core/auth/auth_session.dart';
import 'package:li_on/core/network/token_storage.dart';

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

  test('닉네임 동기화 시 세션과 기기 저장소의 사용자 정보를 함께 바꾼다', () async {
    final session = AuthSessionController();
    addTearDown(session.dispose);
    final storage = _MemoryTokenStorage();
    session.restore(user);

    await syncSessionNickname(session, storage, '새 닉네임');

    expect(session.isAuthenticated, isTrue);
    expect(session.user?.nickname, '새 닉네임');
    expect(session.user?.userId, user.userId);
    expect(storage.savedUser?.nickname, '새 닉네임');
  });

  test('닉네임이 같거나 로그인 사용자가 없으면 저장하지 않는다', () async {
    final session = AuthSessionController();
    addTearDown(session.dispose);
    final storage = _MemoryTokenStorage();

    await syncSessionNickname(session, storage, '새 닉네임');
    session.restore(user);
    await syncSessionNickname(session, storage, user.nickname);

    expect(storage.savedUser, isNull);
  });
}

class _MemoryTokenStorage extends TokenStorage {
  _MemoryTokenStorage() : super(const FlutterSecureStorage());

  AuthUser? savedUser;

  @override
  Future<void> saveUser(AuthUser user) async {
    savedUser = user;
  }
}
