import 'package:json_annotation/json_annotation.dart';

part 'token_refresh_result.g.dart';

/// `POST /api/auth/refresh` 응답.
@JsonSerializable()
class TokenRefreshResult {
  final String accessToken;
  final String tokenType;
  final int expiresIn;

  const TokenRefreshResult({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory TokenRefreshResult.fromJson(Map<String, dynamic> json) =>
      _$TokenRefreshResultFromJson(json);

  Map<String, dynamic> toJson() => _$TokenRefreshResultToJson(this);
}
