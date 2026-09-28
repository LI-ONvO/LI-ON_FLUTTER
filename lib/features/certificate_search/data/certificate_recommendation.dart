import 'package:json_annotation/json_annotation.dart';

part 'certificate_recommendation.g.dart';

/// `GET/POST /api/recommendations` 응답 목록의 추천 자격증 한 건.
@JsonSerializable()
class CertificateRecommendationItem {
  final String jmCd;
  final String name;

  /// 분류가 없는 자격증은 `null`로 오므로 빈 문자열로 받는다.
  @JsonKey(defaultValue: '')
  final String category;

  final String reason;

  const CertificateRecommendationItem({
    required this.jmCd,
    required this.name,
    required this.category,
    required this.reason,
  });

  factory CertificateRecommendationItem.fromJson(Map<String, dynamic> json) =>
      _$CertificateRecommendationItemFromJson(json);

  Map<String, dynamic> toJson() => _$CertificateRecommendationItemToJson(this);
}

/// `GET/POST /api/recommendations` 응답. `generatedAt`은 생성(POST) 응답에만 온다.
@JsonSerializable()
class CertificateRecommendationResult {
  final int recommendationId;
  final List<CertificateRecommendationItem> items;
  final DateTime? generatedAt;

  const CertificateRecommendationResult({
    required this.recommendationId,
    required this.items,
    this.generatedAt,
  });

  factory CertificateRecommendationResult.fromJson(
    Map<String, dynamic> json,
  ) => _$CertificateRecommendationResultFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CertificateRecommendationResultToJson(this);
}
