import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/features/auth/data/auth_user.dart';

class AuthSessionController extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _canAccessOnboarding = false;
  AuthUser? _user;

  bool get isAuthenticated => _isAuthenticated;
  AuthUser? get user => _user;
  bool get canAccessOnboarding => _canAccessOnboarding;

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

  void signOut() {
    _isAuthenticated = false;
    _canAccessOnboarding = false;
    _user = null;
    notifyListeners();
  }

  void startOnboarding() {
    _canAccessOnboarding = true;
    notifyListeners();
  }

  void finishOnboarding() {
    _canAccessOnboarding = false;
    notifyListeners();
  }
}

final authSessionProvider = Provider<AuthSessionController>((ref) {
  final controller = AuthSessionController();
  ref.onDispose(controller.dispose);
  return controller;
});
