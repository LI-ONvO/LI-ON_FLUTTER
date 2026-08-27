import 'package:json_annotation/json_annotation.dart';

part 'chat_history_item.g.dart';

/// 로드맵 챗봇과 나눈 대화(`GET /api/chat/sessions`) 한 건의 요약 정보.
@JsonSerializable()
class ChatHistoryItem {
  final int id;

  /// 대화가 속한 자격증 이름. 목록에서 배지로 노출된다.
  /// API 응답의 `certificate.name`을 옮겨 담는다(연결된 자격증이 없으면 서버가
  /// `certificate: null`을 주므로, 그 경우를 이 값으로 채우는 건 저장소 몫이다).
  final String certificateName;

  /// 대화 내용을 요약한 제목.
  final String title;

  /// 마지막으로 대화한 시각.
  final DateTime updatedAt;

  const ChatHistoryItem({
    required this.id,
    required this.certificateName,
    required this.title,
    required this.updatedAt,
  });

  factory ChatHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$ChatHistoryItemFromJson(json);

  Map<String, dynamic> toJson() => _$ChatHistoryItemToJson(this);

  /// "7/13" 형식의 날짜 표기. intl 의존성이 없어 직접 포맷한다.
  String get updatedAtLabel => '${updatedAt.month}/${updatedAt.day}';

  /// 검색어가 제목·자격증 이름 중 하나에라도 걸리는지 확인한다.
  bool matches(String query) {
    if (query.trim().isEmpty) return true;
    final String keyword = query.trim().toLowerCase();
    return title.toLowerCase().contains(keyword) ||
        certificateName.toLowerCase().contains(keyword);
  }
}
