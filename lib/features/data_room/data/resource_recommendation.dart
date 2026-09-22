import 'package:json_annotation/json_annotation.dart';

part 'resource_recommendation.g.dart';

/// `POST /api/resources/recommendations` 응답 목록의 추천 자료 한 건.
@JsonSerializable()
class ResourceRecommendationItem {
  final String title;
  final String url;
  final String reason;

  const ResourceRecommendationItem({
    required this.title,
    required this.url,
    required this.reason,
  });

  factory ResourceRecommendationItem.fromJson(Map<String, dynamic> json) =>
      _$ResourceRecommendationItemFromJson(json);

  Map<String, dynamic> toJson() => _$ResourceRecommendationItemToJson(this);
}

/// `POST /api/resources/recommendations` 응답.
/// 이미 아카이빙한 자료는 서버가 url 기준으로 제외하고 돌려준다.
@JsonSerializable()
class ResourceRecommendationResult {
  final String jmCd;
  final DateTime generatedAt;
  final List<ResourceRecommendationItem> items;

  const ResourceRecommendationResult({
    required this.jmCd,
    required this.generatedAt,
    required this.items,
  });

  factory ResourceRecommendationResult.fromJson(Map<String, dynamic> json) =>
      _$ResourceRecommendationResultFromJson(json);

  Map<String, dynamic> toJson() => _$ResourceRecommendationResultToJson(this);
}
