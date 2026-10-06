import 'package:li_on/features/chat/data/chat_message.dart';

class RoadmapChatState {
  final List<ChatMessage> messages;
  final bool isBotTyping;

  /// 서버에 만들어진 채팅 세션 ID. 첫 메시지를 보내기 전(새 대화)에는 null.
  final int? sessionId;

  /// 이 대화가 연결된 자격증의 jmCd. 자료 추천 진입점을 보여줄지 결정한다.
  final String? jmCd;

  const RoadmapChatState({
    this.messages = const [],
    this.isBotTyping = false,
    this.sessionId,
    this.jmCd,
  });

  RoadmapChatState copyWith({
    List<ChatMessage>? messages,
    bool? isBotTyping,
    int? sessionId,
    String? jmCd,
  }) {
    return RoadmapChatState(
      messages: messages ?? this.messages,
      isBotTyping: isBotTyping ?? this.isBotTyping,
      sessionId: sessionId ?? this.sessionId,
      jmCd: jmCd ?? this.jmCd,
    );
  }
}
