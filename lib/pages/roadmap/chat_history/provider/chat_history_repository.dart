import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/pages/roadmap/chat_history/model/chat_history_item.dart';
import 'package:li_on/pages/roadmap/model/chat_session.dart';
import 'package:li_on/pages/roadmap/provider/roadmap_repository.dart';

/// 대화 내역 목록을 가져오는 방법을 추상화한다.
abstract class ChatHistoryRepository {
  Future<List<ChatHistoryItem>> fetchChatHistories();
}

final chatHistoryRepositoryProvider = Provider<ChatHistoryRepository>((ref) {
  return HttpChatHistoryRepository(ref.watch(roadmapRepositoryProvider));
});

/// `GET /api/chat/sessions` 응답을 화면 모델로 옮겨 담는 실제 구현체.
class HttpChatHistoryRepository implements ChatHistoryRepository {
  HttpChatHistoryRepository(this._roadmaps);

  final RoadmapRepository _roadmaps;

  @override
  Future<List<ChatHistoryItem>> fetchChatHistories() async {
    final ChatSessionListResult result = await _roadmaps.fetchSessions(
      page: 0,
      size: 100,
    );
    return result.content
        .map(
          (session) => ChatHistoryItem(
            id: session.id,
            // 연결된 자격증이 없는 세션은 배지가 비지 않도록 '기타'로 채운다.
            certificateName: session.certificate?.name ?? '기타',
            title: session.title,
            updatedAt: session.updatedAt,
          ),
        )
        .toList();
  }
}

final chatHistoriesProvider = FutureProvider<List<ChatHistoryItem>>((ref) {
  return ref.watch(chatHistoryRepositoryProvider).fetchChatHistories();
});
