import 'package:json_annotation/json_annotation.dart';

part 'email_verification.g.dart';

/// `POST /api/auth/email/send-code` 응답.
@JsonSerializable()
class EmailSendCodeResult {
  final String email;

  /// 인증코드 유효 시간(초).
  final int expiresIn;

  const EmailSendCodeResult({required this.email, required this.expiresIn});

  factory EmailSendCodeResult.fromJson(Map<String, dynamic> json) =>
      _$EmailSendCodeResultFromJson(json);

  Map<String, dynamic> toJson() => _$EmailSendCodeResultToJson(this);
}

/// `POST /api/auth/email/verify-code` 응답.
@JsonSerializable()
class EmailVerifyCodeResult {
  final String email;
  final bool verified;

  /// 회원가입 요청 시 함께 제출해야 하는 인증 완료 토큰.
  final String verificationToken;

  const EmailVerifyCodeResult({
    required this.email,
    required this.verified,
    required this.verificationToken,
  });

  factory EmailVerifyCodeResult.fromJson(Map<String, dynamic> json) =>
      _$EmailVerifyCodeResultFromJson(json);

  Map<String, dynamic> toJson() => _$EmailVerifyCodeResultToJson(this);
}

/// `GET /api/auth/check-email` 응답.
@JsonSerializable()
class EmailCheckResult {
  final bool available;

  const EmailCheckResult({required this.available});

  factory EmailCheckResult.fromJson(Map<String, dynamic> json) =>
      _$EmailCheckResultFromJson(json);

  Map<String, dynamic> toJson() => _$EmailCheckResultToJson(this);
}
