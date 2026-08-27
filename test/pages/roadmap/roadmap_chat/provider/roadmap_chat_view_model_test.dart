import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/pages/roadmap/roadmap_chat/provider/roadmap_chat_repository.dart';
import 'package:li_on/pages/roadmap/roadmap_chat/provider/roadmap_chat_view_model.dart';

/// 서버 대신 세션 ID별로 미리 정한 메시지를 돌려주는 가짜 저장소.
class _FakeRoadmapChatRepository implements RoadmapChatRepository {
  @override
  Future<int> createSession({required String certificateName}) async => 100;

  @override
  Future<List<ChatMessage>> fetchMessages(int sessionId) async {
    return [
      ChatMessage(
        id: sessionId,
        sender: ChatSender.bot,
        text: '세션 $sessionId의 과거 메시지',
        timestamp: DateTime(2026, 7, 1),
      ),
    ];
  }

  @override
  Future<ChatMessage> sendMessage({
    required int sessionId,
    required String content,
  }) async {
    return ChatMessage(
      id: sessionId * 10,
      sender: ChatSender.bot,
      text: '세션 $sessionId의 답변: $content',
      timestamp: DateTime(2026, 7, 1, 12),
    );
  }
}

void main() {
  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        roadmapChatRepositoryProvider.overrideWithValue(
          _FakeRoadmapChatRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('대화 내역 세션마다 해당하는 메시지를 서버에서 불러온다', () async {
    final container = makeContainer();

    const firstSession = RoadmapChatSession(
      certificateName: '정보처리기사',
      historyId: 1,
    );
    const secondSession = RoadmapChatSession(
      certificateName: '정보처리기사',
      historyId: 2,
    );

    // build가 비동기로 과거 메시지를 불러오므로 마이크로태스크를 흘려보낸다.
    container.read(roadmapChatViewModelProvider(firstSession));
    container.read(roadmapChatViewModelProvider(secondSession));
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    final firstMessages = container
        .read(roadmapChatViewModelProvider(firstSession))
        .messages;
    final secondMessages = container
        .read(roadmapChatViewModelProvider(secondSession))
        .messages;

    expect(firstMessages.last.text, contains('세션 1'));
    expect(secondMessages.last.text, contains('세션 2'));
    expect(firstMessages, isNot(equals(secondMessages)));
  });

  test('새 대화는 인사말로 시작하고, 첫 메시지에 세션을 만들어 답변을 받는다', () async {
    final container = makeContainer();

    const newSession = RoadmapChatSession(certificateName: 'SQLD');
    final provider = roadmapChatViewModelProvider(newSession);

    expect(container.read(provider).messages.single.text, contains('SQLD'));

    await container.read(provider.notifier).sendMessage('3개월 안에 가능해?');

    final messages = container.read(provider).messages;
    expect(messages.length, 3);
    expect(messages.last.text, contains('세션 100의 답변'));
  });
}
