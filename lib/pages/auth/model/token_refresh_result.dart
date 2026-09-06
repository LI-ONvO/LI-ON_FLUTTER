import 'package:json_annotation/json_annotation.dart';

part 'token_refresh_result.g.dart';

/// `POST /api/auth/refresh` 응답.
///
/// `tokenType`·`expiresIn`은 [AuthInterceptor]가 쓰지 않는 부가 정보라,
/// 서버가 안 내려줘도 토큰 갱신(=조용히 백그라운드에서 일어나는 로그인
/// 유지) 자체가 실패해 강제 로그아웃되는 일이 없도록 기본값을 둔다.
@JsonSerializable()
class TokenRefreshResult {
  final String accessToken;

  @JsonKey(defaultValue: 'Bearer')
  final String tokenType;

  @JsonKey(defaultValue: 0)
  final int expiresIn;

  const TokenRefreshResult({
    required this.accessToken,
    this.tokenType = 'Bearer',
    this.expiresIn = 0,
  });

  factory TokenRefreshResult.fromJson(Map<String, dynamic> json) =>
      _$TokenRefreshResultFromJson(json);

  Map<String, dynamic> toJson() => _$TokenRefreshResultToJson(this);
}
