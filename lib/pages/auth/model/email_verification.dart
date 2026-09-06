import 'package:json_annotation/json_annotation.dart';

part 'email_verification.g.dart';

/// `POST /api/auth/email/send-code` 응답.
/// 화면에서 값을 쓰지 않고 성공 여부만 확인하므로, 필드가 없어도 안전하게
/// 기본값으로 채운다.
@JsonSerializable()
class EmailSendCodeResult {
  @JsonKey(defaultValue: '')
  final String email;

  /// 인증코드 유효 시간(초).
  @JsonKey(defaultValue: 0)
  final int expiresIn;

  const EmailSendCodeResult({this.email = '', this.expiresIn = 0});

  factory EmailSendCodeResult.fromJson(Map<String, dynamic> json) =>
      _$EmailSendCodeResultFromJson(json);

  Map<String, dynamic> toJson() => _$EmailSendCodeResultToJson(this);
}

/// `POST /api/auth/email/verify-code` 응답.
@JsonSerializable()
class EmailVerifyCodeResult {
  @JsonKey(defaultValue: '')
  final String email;

  /// 서버가 값을 안 주면 인증이 안 된 것으로 본다(안전 실패).
  @JsonKey(defaultValue: false)
  final bool verified;

  /// 회원가입 요청 시 함께 제출해야 하는 인증 완료 토큰.
  /// 서버가 이 필드 없이 `verified`만 내려주는 경우도 있어 optional로 둔다.
  final String? verificationToken;

  const EmailVerifyCodeResult({
    this.email = '',
    this.verified = false,
    this.verificationToken,
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
