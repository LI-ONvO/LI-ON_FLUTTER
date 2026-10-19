import 'package:json_annotation/json_annotation.dart';

part 'roadmap_summary.g.dart';

/// `GET /api/chat/sessions/{sessionId}/roadmaps` 목록의 항목 한 건.
/// 스텝은 담기지 않아 `GET /api/roadmaps/{roadmapId}`로 따로 읽는다.
@JsonSerializable()
class RoadmapSummary {
  final int id;
  final String title;
  final DateTime createdAt;

  const RoadmapSummary({
    required this.id,
    required this.title,
    required this.createdAt,
  });

  factory RoadmapSummary.fromJson(Map<String, dynamic> json) =>
      _$RoadmapSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$RoadmapSummaryToJson(this);
}
