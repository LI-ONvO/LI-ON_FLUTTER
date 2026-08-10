import 'package:json_annotation/json_annotation.dart';

part 'chat_message.g.dart';

enum ChatSender { bot, user }

/// 화면에서 바텀시트를 띄우는 퀵 액션 id들.
/// 나머지 액션은 뷰모델이 확인 메시지로만 처리한다.
const String addToCalendarActionId = 'add_to_calendar';
const String saveToMaterialsActionId = 'save_to_materials';

@JsonSerializable()
class ChatQuickAction {
  final String id;
  final String label;

  const ChatQuickAction({required this.id, required this.label});

  factory ChatQuickAction.fromJson(Map<String, dynamic> json) =>
      _$ChatQuickActionFromJson(json);

  Map<String, dynamic> toJson() => _$ChatQuickActionToJson(this);
}

@JsonSerializable()
class ChatMessage {
  final String id;
  final ChatSender sender;
  final String text;
  final DateTime timestamp;
  final List<ChatQuickAction> actions;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.actions = const [],
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
