import 'package:json_annotation/json_annotation.dart';
import 'package:li_on/core/utils/json_converters.dart';

part 'chat_message.g.dart';

/// 서버 값(`USER`/`AI`)과 매핑된다.
enum ChatSender {
  @JsonValue('AI')
  bot,
  @JsonValue('USER')
  user,
}

/// 로드맵 채팅 메시지 한 건. `sender`/`content`/`createdAt`은
/// `POST /api/chat/sessions/{sessionId}/messages` 등 채팅 API 응답과 맞췄다.
@JsonSerializable()
class ChatMessage {
  final int id;
  final ChatSender sender;

  @JsonKey(name: 'content')
  final String text;

  @JsonKey(name: 'createdAt', fromJson: localDateTimeFromJson)
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);
}

/// "오전 9:12" 형식의 시각 표기.
/// intl 의존성이 없어 직접 포맷한다.
extension ChatMessageTimeFormat on DateTime {
  String get toKoreanTimeLabel {
    final bool isAm = hour < 12;
    final int hour12 = hour % 12 == 0 ? 12 : hour % 12;
    final String minuteLabel = minute.toString().padLeft(2, '0');
    return '${isAm ? '오전' : '오후'} $hour12:$minuteLabel';
  }
}
