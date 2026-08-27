import 'package:json_annotation/json_annotation.dart';
import 'package:li_on/pages/auth/model/auth_user.dart';

part 'login_result.g.dart';

/// `POST /api/auth/login` 응답.
@JsonSerializable()
class LoginResult {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final AuthUser user;
  final bool isFirstLogin;

  const LoginResult({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
    required this.isFirstLogin,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) =>
      _$LoginResultFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResultToJson(this);
}
