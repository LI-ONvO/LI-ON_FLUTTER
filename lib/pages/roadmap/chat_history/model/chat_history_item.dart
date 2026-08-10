import 'package:json_annotation/json_annotation.dart';

part 'chat_history_item.g.dart';

/// 로드맵 챗봇과 나눈 대화 한 건의 요약 정보.
@JsonSerializable()
class ChatHistoryItem {
  final String id;

  /// 대화가 속한 자격증 이름. 목록에서 배지로 노출된다.
  final String certificateName;

  /// 대화 내용을 요약한 제목.
  final String title;

  /// 마지막으로 대화한 시각.
  final DateTime updatedAt;

  final int messageCount;

  /// 대화 안에서 학습 계획이 만들어졌는지 여부. true면 '계획 포함' 배지가 붙는다.
  final bool hasPlan;

  const ChatHistoryItem({
    required this.id,
    required this.certificateName,
    required this.title,
    required this.updatedAt,
    required this.messageCount,
    this.hasPlan = false,
  });

  factory ChatHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$ChatHistoryItemFromJson(json);

  Map<String, dynamic> toJson() => _$ChatHistoryItemToJson(this);

  /// "7/13" 형식의 날짜 표기. intl 의존성이 없어 직접 포맷한다.
  String get updatedAtLabel => '${updatedAt.month}/${updatedAt.day}';

  String get messageCountLabel => '$messageCount개 메시지';

  /// 검색어가 제목·자격증 이름 중 하나에라도 걸리는지 확인한다.
  bool matches(String query) {
    if (query.trim().isEmpty) return true;
    final String keyword = query.trim().toLowerCase();
    return title.toLowerCase().contains(keyword) ||
        certificateName.toLowerCase().contains(keyword);
  }
}
