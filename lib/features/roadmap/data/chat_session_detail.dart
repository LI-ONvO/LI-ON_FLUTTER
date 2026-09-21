import 'package:json_annotation/json_annotation.dart';
import 'package:li_on/features/certificate_search/data/certificate.dart';
import 'package:li_on/features/roadmap_chat/data/chat_message.dart';

part 'chat_session_detail.g.dart';

/// `GET /api/chat/sessions/{sessionId}` 응답.
@JsonSerializable()
class ChatSessionDetail {
  final int id;
  final String title;
  final CertificateRef? certificate;
  final List<ChatMessage> messages;

  const ChatSessionDetail({
    required this.id,
    required this.title,
    this.certificate,
    required this.messages,
  });

  factory ChatSessionDetail.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ChatSessionDetailToJson(this);
}
