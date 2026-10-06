import 'package:json_annotation/json_annotation.dart';
import 'package:li_on/features/certificate_search/data/certificate.dart';

part 'chat_session.g.dart';

/// `GET /api/chat/sessions` 목록의 세션 한 건.
@JsonSerializable()
class ChatSessionSummary {
  final int id;
  final String title;
  final CertificateRef? certificate;
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

/// 화면은 [content]만 쓰고 페이지 정보는 아직 안 써서, 서버의 페이지네이션
/// 응답 형태(필드명 등)가 예상과 달라도 목록 자체는 파싱되게 기본값을 둔다.
@JsonSerializable()
class ChatSessionListResult {
  final List<ChatSessionSummary> content;

  @JsonKey(defaultValue: 0)
  final int page;

  @JsonKey(defaultValue: 0)
  final int totalElements;

  @JsonKey(defaultValue: 0)
  final int totalPages;

  const ChatSessionListResult({
    required this.content,
    this.page = 0,
    this.totalElements = 0,
    this.totalPages = 0,
  });

  factory ChatSessionListResult.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionListResultFromJson(json);

  Map<String, dynamic> toJson() => _$ChatSessionListResultToJson(this);
}

/// `POST /api/chat/sessions` 응답: `{ id, title, jmCd, createdAt }`.
@JsonSerializable()
class ChatSessionCreateResult {
  final int id;
  final String title;
  final String? jmCd;
  final DateTime createdAt;

  const ChatSessionCreateResult({
    required this.id,
    required this.title,
    this.jmCd,
    required this.createdAt,
  });

  factory ChatSessionCreateResult.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionCreateResultFromJson(json);

  Map<String, dynamic> toJson() => _$ChatSessionCreateResultToJson(this);
}
