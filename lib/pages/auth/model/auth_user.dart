import 'package:json_annotation/json_annotation.dart';

part 'auth_user.g.dart';

/// 로그인 응답에 함께 오는 사용자 요약 정보.
@JsonSerializable()
class AuthUser {
  final int userId;
  final String email;
  final String nickname;

  const AuthUser({
    required this.userId,
    required this.email,
    required this.nickname,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);

  Map<String, dynamic> toJson() => _$AuthUserToJson(this);
}
