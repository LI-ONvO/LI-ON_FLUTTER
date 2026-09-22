import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/features/roadmap/data/roadmap_message_result.dart';
import 'package:li_on/features/roadmap/data/roadmap_repository.dart';
import 'package:li_on/features/roadmap/data/chat_message.dart';

/// AI 로드맵 챗봇과의 메시지 교환을 추상화한다.
/// 실제 대화는 서버의 채팅 세션 단위로 오가므로, 세션 생성·내역 조회·
/// 메시지 전송을 함께 묶었다.
abstract class RoadmapChatRepository {
  /// 새 채팅 세션을 만들고 세션 ID를 돌려준다.
  Future<int> createSession({required String certificateName});

  /// 세션의 과거 메시지 내역.
  Future<List<ChatMessage>> fetchMessages(int sessionId);

  /// 사용자 메시지를 보내고 AI 응답 메시지를 돌려받는다.
  Future<ChatMessage> sendMessage({
    required int sessionId,
    required String content,
  });
}

/// 채팅 세션·메시지 API(`/api/chat/sessions/**`)를 쓰는 실제 구현체.
class HttpRoadmapChatRepository implements RoadmapChatRepository {
  HttpRoadmapChatRepository(this._roadmaps);

  final RoadmapRepository _roadmaps;

  @override
  Future<int> createSession({required String certificateName}) async {
    final result = await _roadmaps.createSession(
      title: '$certificateName 로드맵',
    );
    return result.id;
  }

  @override
  Future<List<ChatMessage>> fetchMessages(int sessionId) async {
    final detail = await _roadmaps.fetchSessionDetail(sessionId);
    return detail.messages;
  }

  @override
  Future<ChatMessage> sendMessage({
    required int sessionId,
    required String content,
  }) async {
    final RoadmapMessageResult result = await _roadmaps.sendMessage(
      sessionId: sessionId,
      content: content,
    );
    return result.aiMessage;
  }
}

final roadmapChatRepositoryProvider = Provider<RoadmapChatRepository>((ref) {
  return HttpRoadmapChatRepository(ref.watch(roadmapRepositoryProvider));
});
