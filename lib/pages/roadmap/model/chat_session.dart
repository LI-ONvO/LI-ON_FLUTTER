import 'package:json_annotation/json_annotation.dart';
import 'package:li_on/pages/certificate_search/model/certificate_detail.dart';

part 'chat_session.g.dart';

/// `GET /api/chat/sessions` 목록의 세션 한 건.
@JsonSerializable()
class ChatSessionSummary {
  final int id;
  final String title;
  final CertificateField? certificate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatSessionSummary({
    required this.id,
    required this.title,
    this.certificate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatSessionSummary.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$ChatSessionSummaryToJson(this);
}

@JsonSerializable()
class ChatSessionListResult {
  final List<ChatSessionSummary> content;
  final int page;
  final int totalElements;
  final int totalPages;

  const ChatSessionListResult({
    required this.content,
    required this.page,
    required this.totalElements,
    required this.totalPages,
  });

  factory ChatSessionListResult.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionListResultFromJson(json);

  Map<String, dynamic> toJson() => _$ChatSessionListResultToJson(this);
}

/// `POST /api/chat/sessions` 응답. 목록 항목과 달리 자격증을 id로만 돌려준다.
@JsonSerializable()
class ChatSessionCreateResult {
  final int id;
  final String title;
  final int? certificateId;
  final DateTime createdAt;

  const ChatSessionCreateResult({
    required this.id,
    required this.title,
    this.certificateId,
    required this.createdAt,
  });

  factory ChatSessionCreateResult.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionCreateResultFromJson(json);

  Map<String, dynamic> toJson() => _$ChatSessionCreateResultToJson(this);
}
