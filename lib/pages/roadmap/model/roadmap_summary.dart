import 'package:json_annotation/json_annotation.dart';

part 'roadmap_summary.g.dart';

/// `GET /api/chat/sessions/{sessionId}/roadmaps` 목록의 로드맵 한 건.
@JsonSerializable()
class RoadmapSummary {
  final int id;
  final String title;
  final int stepCount;
  final DateTime createdAt;

  const RoadmapSummary({
    required this.id,
    required this.title,
    required this.stepCount,
    required this.createdAt,
  });

  factory RoadmapSummary.fromJson(Map<String, dynamic> json) =>
      _$RoadmapSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$RoadmapSummaryToJson(this);
}
