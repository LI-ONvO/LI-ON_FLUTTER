import 'package:json_annotation/json_annotation.dart';

part 'roadmap_summary.g.dart';

/// `GET /api/chat/sessions/{sessionId}/roadmaps` 목록의 항목 한 건.
/// 명세서 기준 응답 형태: `{ id, title, description, orderNo, targetDate }`.
@JsonSerializable()
class RoadmapSummary {
  final int id;
  final String title;
  final String description;
  final int orderNo;

  /// 목표 일자. 없을 수 있다.
  final DateTime? targetDate;

  const RoadmapSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.orderNo,
    this.targetDate,
  });

  factory RoadmapSummary.fromJson(Map<String, dynamic> json) =>
      _$RoadmapSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$RoadmapSummaryToJson(this);
}
