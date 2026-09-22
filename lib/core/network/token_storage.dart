import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/auth/auth_user.dart';

class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _userKey = 'authUser';
  String? _accessToken;
  String? _refreshToken;
  AuthUser? _user;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  Future<String?> readAccessToken() async {
    return _accessToken ??= await _storage.read(key: _accessTokenKey);
  }

  Future<String?> readRefreshToken() async {
    return _refreshToken ??= await _storage.read(key: _refreshTokenKey);
  }

  Future<void> saveUser(AuthUser user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
    _user = user;
  }

  Future<AuthUser?> readUser() async {
    if (_user != null) return _user;
    final String? encoded = await _storage.read(key: _userKey);
    if (encoded == null) return null;
    try {
      final Object? decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic>) return null;
      return _user = AuthUser.fromJson(decoded);
    } on FormatException {
      return null;
    }
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userKey);
    _accessToken = null;
    _refreshToken = null;
    _user = null;
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(const FlutterSecureStorage());
});
