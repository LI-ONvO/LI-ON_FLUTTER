import 'package:json_annotation/json_annotation.dart';
import 'package:li_on/features/roadmap_chat/data/chat_message.dart';

part 'roadmap_message_result.g.dart';

/// `POST /api/chat/sessions/{sessionId}/messages` 응답.
@JsonSerializable()
class RoadmapMessageResult {
  /// 클라이언트가 이미 낙관적으로 표시한 내 메시지를 서버가 그대로 다시
  /// 돌려주지 않는 경우가 있어(AI 응답만 오는 응답도 존재) optional로 둔다.
  /// 실제로 화면에서 쓰는 값도 [aiMessage]뿐이다.
  final ChatMessage? userMessage;
  final ChatMessage aiMessage;

  const RoadmapMessageResult({this.userMessage, required this.aiMessage});

  factory RoadmapMessageResult.fromJson(Map<String, dynamic> json) =>
      _$RoadmapMessageResultFromJson(json);

  Map<String, dynamic> toJson() => _$RoadmapMessageResultToJson(this);
}
