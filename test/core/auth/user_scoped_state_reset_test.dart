import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/core/auth/auth_session.dart';
import 'package:li_on/core/auth/auth_user.dart';
import 'package:li_on/core/auth/user_scoped_state_reset.dart';
import 'package:li_on/features/auth/presentation/view_models/login_view_model.dart';
import 'package:li_on/features/auth/presentation/view_models/sign_in_view_model.dart';
import 'package:li_on/features/my/data/profile.dart';
import 'package:li_on/features/my/data/user_repository.dart';

void main() {
  const user = AuthUser(
    userId: 1,
    email: 'user@example.com',
    nickname: '테스트 사용자',
  );

  late ProviderContainer container;
  late AuthSessionController authSession;
  late int profileFetchCount;

  setUp(() {
    profileFetchCount = 0;
    container = ProviderContainer(
      overrides: [
        myProfileProvider.overrideWith((ref) async {
          profileFetchCount++;
          return const Profile(
            id: 1,
            email: 'user@example.com',
            nickname: '테스트 사용자',
            desiredFields: [],
            isOnboarded: true,
          );
        }),
      ],
    );
    addTearDown(container.dispose);
    authSession = container.read(authSessionProvider);
    resetUserScopedStateOnSignOut(container);
  });

  test('로그인 상태에서 로그아웃하면 사용자별 입력 상태를 초기화한다', () {
    authSession.signIn(user);
    container.read(loginViewModelProvider.notifier).setEmail('a@b.com');
    container.read(signInViewModelProvider.notifier).setNickname('닉네임');

    authSession.signOut();

    expect(container.read(loginViewModelProvider).email, isEmpty);
    expect(container.read(signInViewModelProvider).nickname, isEmpty);
  });

  test('세션이 만료돼 로그아웃되면 캐시된 서버 데이터를 다시 불러온다', () async {
    authSession.restore(user);
    await container.read(myProfileProvider.future);
    expect(profileFetchCount, 1);

    // AuthInterceptor가 토큰 갱신에 실패하면 onSessionExpired로 signOut을
    // 부른다. 직접 로그아웃과 같은 경로다.
    authSession.signOut();
    await container.read(myProfileProvider.future);

    expect(profileFetchCount, 2);
  });

  test('이미 로그아웃된 상태에서 signOut이 다시 불려도 초기화하지 않는다', () {
    authSession.signIn(user);
    authSession.signOut();
    container.read(loginViewModelProvider.notifier).setEmail('a@b.com');

    authSession.signOut();

    expect(container.read(loginViewModelProvider).email, 'a@b.com');
  });

  test('로그인할 때는 초기화하지 않는다', () {
    container.read(loginViewModelProvider.notifier).setEmail('a@b.com');

    authSession.signIn(user);

    expect(container.read(loginViewModelProvider).email, 'a@b.com');
  });

  test('회원가입 직후 온보딩 중에 세션이 만료되면 사용자별 상태를 초기화한다', () {
    authSession.startOnboarding(user: user);
    container.read(signInViewModelProvider.notifier).setNickname('닉네임');

    authSession.signOut();

    expect(container.read(signInViewModelProvider).nickname, isEmpty);
  });

  test('회원가입 직후 온보딩을 마쳐 로그인되면 초기화하지 않는다', () {
    authSession.startOnboarding(user: user);
    container.read(signInViewModelProvider.notifier).setNickname('닉네임');

    authSession.finishOnboarding();

    expect(authSession.isAuthenticated, isTrue);
    expect(container.read(signInViewModelProvider).nickname, '닉네임');
  });
}
