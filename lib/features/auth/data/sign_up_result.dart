import 'package:json_annotation/json_annotation.dart';

part 'sign_up_result.g.dart';

/// `POST /api/auth/signup` 응답.
/// 가입 화면은 이 값을 쓰지 않고 요청 성공 여부만 확인하므로(회원가입 뒤
/// 바로 로그인 화면으로 이동), 서버가 일부 필드를 안 내려줘도 "가입은
/// 됐는데 화면에는 실패로 뜨는" 일이 없도록 전부 optional로 둔다.
@JsonSerializable()
class SignUpResult {
  final int? userId;
  final String? email;
  final String? nickname;
  final DateTime? createdAt;

  const SignUpResult({this.userId, this.email, this.nickname, this.createdAt});

  factory SignUpResult.fromJson(Map<String, dynamic> json) =>
      _$SignUpResultFromJson(json);

  Map<String, dynamic> toJson() => _$SignUpResultToJson(this);
}
