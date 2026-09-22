import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/features/roadmap/data/roadmap_message_result.dart';
import 'package:li_on/features/roadmap/data/roadmap_repository.dart';
import 'package:li_on/features/roadmap/data/chat_message.dart';

/// 세션 상세 조회 결과. 메시지 내역과 함께, "자료 추천" 같은 자격증
/// 종속 기능이 필요로 하는 연결된 자격증(jmCd)도 같이 돌려준다.
typedef RoadmapChatSessionDetail = ({List<ChatMessage> messages, String? jmCd});

/// AI 로드맵 챗봇과의 메시지 교환을 추상화한다.
/// 실제 대화는 서버의 채팅 세션 단위로 오가므로, 세션 생성·내역 조회·
/// 메시지 전송을 함께 묶었다.
abstract class RoadmapChatRepository {
  /// 새 채팅 세션을 만들고 세션 ID를 돌려준다. [jmCd]를 주면 특정 자격증에
  /// 연결된 세션이 되어, 이후 자료 추천 등 자격증 종속 기능을 쓸 수 있다.
  Future<int> createSession({required String certificateName, String? jmCd});

  /// 세션의 과거 메시지 내역과 연결된 자격증(jmCd).
  Future<RoadmapChatSessionDetail> fetchSessionDetail(int sessionId);

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
  Future<int> createSession({
    required String certificateName,
    String? jmCd,
  }) async {
    final result = await _roadmaps.createSession(
      jmCd: jmCd,
      title: '$certificateName 로드맵',
    );
    return result.id;
  }

  @override
  Future<RoadmapChatSessionDetail> fetchSessionDetail(int sessionId) async {
    final detail = await _roadmaps.fetchSessionDetail(sessionId);
    return (messages: detail.messages, jmCd: detail.certificate?.jmCd);
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
