import 'package:json_annotation/json_annotation.dart';

part 'certificate_recommendation.g.dart';

/// `GET/POST /api/recommendations` 응답 목록의 추천 자격증 한 건.
@JsonSerializable()
class CertificateRecommendationItem {
  final String jmCd;
  final String name;
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
