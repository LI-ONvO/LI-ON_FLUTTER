import 'package:json_annotation/json_annotation.dart';

part 'roadmap_detail.g.dart';

@JsonSerializable()
class RoadmapStep {
  final int id;
  final String title;
  final String description;
  final int orderNo;

  /// 목표 일자. 없을 수 있다.
  final DateTime? targetDate;

  const RoadmapStep({
    required this.id,
    required this.title,
    required this.description,
    required this.orderNo,
    this.targetDate,
  });

  factory RoadmapStep.fromJson(Map<String, dynamic> json) =>
      _$RoadmapStepFromJson(json);

  Map<String, dynamic> toJson() => _$RoadmapStepToJson(this);
}

/// `GET /api/roadmaps/{roadmapId}`와 `POST /api/chat/sessions/{sessionId}/roadmaps`
/// 응답을 함께 표현한다. 후자는 `sessionId`가 오지 않아 nullable로 둔다.
@JsonSerializable()
class RoadmapDetail {
  final int id;
  final int? sessionId;
  final String title;
  final List<RoadmapStep> steps;

  const RoadmapDetail({
    required this.id,
    this.sessionId,
    required this.title,
    required this.steps,
  });

  factory RoadmapDetail.fromJson(Map<String, dynamic> json) =>
      _$RoadmapDetailFromJson(json);

  Map<String, dynamic> toJson() => _$RoadmapDetailToJson(this);
}
