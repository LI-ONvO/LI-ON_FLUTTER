import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/auth/auth_user.dart';
import 'package:li_on/core/network/token_storage.dart';

class AuthSessionController extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _canAccessOnboarding = false;
  AuthUser? _user;
  AuthUser? _onboardingUser;

  bool get isAuthenticated => _isAuthenticated;
  AuthUser? get user => _user;
  bool get canAccessOnboarding => _canAccessOnboarding;

  /// 회원가입 직후 온보딩 중인 사용자. 가입 때 이미 로그인해 토큰은 받아
  /// 뒀지만, 온보딩을 마칠 때까지는 세션을 로그인 상태로 바꾸지 않는다
  /// (바꾸면 라우터가 가입 화면에서 곧바로 탐색 화면으로 보내 버린다).
  AuthUser? get onboardingUser => _onboardingUser;

  void restore(AuthUser? user) {
    _isAuthenticated = true;
    _user = user;
    notifyListeners();
  }

  void signIn(AuthUser user) {
    _isAuthenticated = true;
    _user = user;
    notifyListeners();
  }

  /// 로그인 상태는 그대로 두고 사용자 정보만 바꾼다(예: 닉네임 수정).
  void updateUser(AuthUser user) {
    _user = user;
    notifyListeners();
  }

  void signOut() {
    _isAuthenticated = false;
    _canAccessOnboarding = false;
    _user = null;
    _onboardingUser = null;
    notifyListeners();
  }

  void startOnboarding({AuthUser? user}) {
    _canAccessOnboarding = true;
    _onboardingUser = user;
    notifyListeners();
  }

  /// 온보딩을 마친다. 회원가입 직후라면 가입 때 받아 둔 사용자로 로그인
  /// 상태까지 한 번에 바꾼다. 두 단계로 나눠 알리면 그 사이에 "세션 없음"
  /// 상태가 잠깐 보여, 로그아웃 감지가 이를 로그아웃으로 착각한다.
  void finishOnboarding() {
    if (!_isAuthenticated && _onboardingUser != null) {
      _isAuthenticated = true;
      _user = _onboardingUser;
    }
    _canAccessOnboarding = false;
    _onboardingUser = null;
    notifyListeners();
  }
}

final authSessionProvider = Provider<AuthSessionController>((ref) {
  final controller = AuthSessionController();
  ref.onDispose(controller.dispose);
  return controller;
});

/// 서버에 저장된 닉네임을 세션과 기기 저장소의 사용자 정보에 반영한다.
/// 저장소 값은 앱을 다시 켤 때 세션 복원에 쓰이므로, 둘 다 고쳐야 재실행
/// 후에도 예전 닉네임이 보이지 않는다. 이미 같으면 아무것도 하지 않는다.
Future<void> syncSessionNickname(
  AuthSessionController session,
  TokenStorage storage,
  String nickname,
) async {
  final AuthUser? user = session.user;
  if (user == null || user.nickname == nickname) return;
  final AuthUser updated = AuthUser(
    userId: user.userId,
    email: user.email,
    nickname: nickname,
  );
  session.updateUser(updated);
  await storage.saveUser(updated);
}
