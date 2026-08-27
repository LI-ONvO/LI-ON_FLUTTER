import 'package:json_annotation/json_annotation.dart';

part 'sign_up_result.g.dart';

/// `POST /api/auth/signup` 응답.
@JsonSerializable()
class SignUpResult {
  final int userId;
  final String email;
  final String nickname;
  final DateTime createdAt;

  const SignUpResult({
    required this.userId,
    required this.email,
    required this.nickname,
    required this.createdAt,
  });

  factory SignUpResult.fromJson(Map<String, dynamic> json) =>
      _$SignUpResultFromJson(json);

  Map<String, dynamic> toJson() => _$SignUpResultToJson(this);
}
