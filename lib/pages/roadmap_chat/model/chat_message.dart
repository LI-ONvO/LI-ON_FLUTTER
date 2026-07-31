enum ChatSender { bot, user }

class ChatQuickAction {
  final String id;
  final String label;

  const ChatQuickAction({required this.id, required this.label});
}

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
