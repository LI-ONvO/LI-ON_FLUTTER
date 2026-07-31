import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/pages/roadmap_chat/model/chat_message.dart';

/// AI 로드맵 챗봇과의 메시지 교환을 추상화한다.
/// 실제 API 연동 시에는 이 인터페이스를 구현하는 클래스를 새로 만들고
/// [roadmapChatRepositoryProvider]의 구현체만 교체하면 된다.
abstract class RoadmapChatRepository {
  Future<ChatMessage> sendMessage({
    required String certificateName,
    required List<ChatMessage> history,
    required String userText,
  });
}

/// 실제 AI 챗봇 API가 준비되기 전까지 사용하는 더미 구현체.
class DummyRoadmapChatRepository implements RoadmapChatRepository {
  const DummyRoadmapChatRepository();

  @override
  Future<ChatMessage> sendMessage({
    required String certificateName,
    required List<ChatMessage> history,
    required String userText,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final bool isFirstUserReply =
        history.where((message) => message.sender == ChatSender.user).length <=
        1;

    final DateTime now = DateTime.now();
    if (isFirstUserReply) {
      return ChatMessage(
        id: 'bot-${now.microsecondsSinceEpoch}',
        sender: ChatSender.bot,
        text:
            '좋아요, 말씀해주신 기간을 기준으로 필기·실기 계획을 짜드렸어요. '
            '주차별 학습 계획을 캘린더에 추가하거나 자료방에 저장할 수 있어요.',
        timestamp: now,
        actions: const [
          ChatQuickAction(id: 'add_to_calendar', label: '캘린더에 추가'),
          ChatQuickAction(id: 'save_to_materials', label: '자료방에 저장'),
        ],
      );
    }

    return ChatMessage(
      id: 'bot-${now.microsecondsSinceEpoch}',
      sender: ChatSender.bot,
      text: '네, 확인했어요! 로드맵을 조금 더 구체화해볼까요?',
      timestamp: now,
    );
  }
}

final roadmapChatRepositoryProvider = Provider<RoadmapChatRepository>((ref) {
  return const DummyRoadmapChatRepository();
});
