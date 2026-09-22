import 'package:json_annotation/json_annotation.dart';
import 'package:li_on/core/auth/auth_user.dart';

part 'login_result.g.dart';

/// `POST /api/auth/login` 응답.
///
/// `expiresIn`·`isFirstLogin`은 현재 화면 어디서도 쓰지 않는 부가 정보라,
/// 서버가 안 내려줘도 로그인 자체는 실패하지 않도록 기본값을 둔다.
@JsonSerializable()
class LoginResult {
  final String accessToken;
  final String refreshToken;

  @JsonKey(defaultValue: 0)
  final int expiresIn;

  final AuthUser user;

  @JsonKey(defaultValue: false)
  final bool isFirstLogin;

  const LoginResult({
    required this.accessToken,
    required this.refreshToken,
    this.expiresIn = 0,
    required this.user,
    this.isFirstLogin = false,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) =>
      _$LoginResultFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResultToJson(this);
}
