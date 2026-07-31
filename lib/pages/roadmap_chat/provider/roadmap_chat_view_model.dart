import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/pages/roadmap_chat/provider/roadmap_chat_repository.dart';
import 'package:li_on/pages/roadmap_chat/model/chat_message.dart';

export 'package:li_on/pages/roadmap_chat/model/chat_message.dart';

class RoadmapChatState {
  final List<ChatMessage> messages;
  final bool isBotTyping;

  const RoadmapChatState({this.messages = const [], this.isBotTyping = false});

  RoadmapChatState copyWith({List<ChatMessage>? messages, bool? isBotTyping}) {
    return RoadmapChatState(
      messages: messages ?? this.messages,
      isBotTyping: isBotTyping ?? this.isBotTyping,
    );
  }
}

/// [certificateName]별로 독립된 대화 상태를 갖는다.
class RoadmapChatViewModel extends Notifier<RoadmapChatState> {
  RoadmapChatViewModel(this.certificateName);

  final String certificateName;

  @override
  RoadmapChatState build() {
    return RoadmapChatState(
      messages: [
        ChatMessage(
          id: 'bot-greeting',
          sender: ChatSender.bot,
          text:
              '안녕하세요! $certificateName 학습 로드맵을 함께 만들어볼게요. '
              '시험까지 남은 기간이 어느 정도인가요?',
          timestamp: DateTime.now(),
        ),
      ],
    );
  }

  Future<void> sendMessage(String text) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty || state.isBotTyping) return;

    final ChatMessage userMessage = ChatMessage(
      id: 'user-${DateTime.now().microsecondsSinceEpoch}',
      sender: ChatSender.user,
      text: trimmed,
      timestamp: DateTime.now(),
    );

    final List<ChatMessage> history = [...state.messages, userMessage];
    state = state.copyWith(messages: history, isBotTyping: true);

    final ChatMessage reply = await ref
        .read(roadmapChatRepositoryProvider)
        .sendMessage(
          certificateName: certificateName,
          history: history,
          userText: trimmed,
        );

    if (!ref.mounted) return;
    state = state.copyWith(
      messages: [...state.messages, reply],
      isBotTyping: false,
    );
  }

  /// 캘린더 추가·자료방 저장 등 챗봇 메시지에 달린 퀵 액션 처리.
  /// 실제 기능이 붙기 전까지는 처리 결과를 확인 메시지로 보여준다.
  void handleQuickAction(ChatQuickAction action) {
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(
          id: 'bot-${DateTime.now().microsecondsSinceEpoch}',
          sender: ChatSender.bot,
          text: '"${action.label}" 완료했어요.',
          timestamp: DateTime.now(),
        ),
      ],
    );
  }
}

/// autoDispose를 붙이지 않아, 화면을 나갔다 다시 들어와도 같은
/// [certificateName]의 대화 내역은 유지된다.
final roadmapChatViewModelProvider =
    NotifierProvider.family<RoadmapChatViewModel, RoadmapChatState, String>(
      (certificateName) => RoadmapChatViewModel(certificateName),
    );
