import 'package:json_annotation/json_annotation.dart';
import 'package:li_on/pages/roadmap/roadmap_chat/model/chat_message.dart';

part 'roadmap_message_result.g.dart';

/// `POST /api/chat/sessions/{sessionId}/messages` 응답.
@JsonSerializable()
class RoadmapMessageResult {
  final ChatMessage userMessage;
  final ChatMessage aiMessage;

  const RoadmapMessageResult({
    required this.userMessage,
    required this.aiMessage,
  });

  factory RoadmapMessageResult.fromJson(Map<String, dynamic> json) =>
      _$RoadmapMessageResultFromJson(json);

  Map<String, dynamic> toJson() => _$RoadmapMessageResultToJson(this);
}
