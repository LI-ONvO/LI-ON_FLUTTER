import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/pages/roadmap/chat_history/model/chat_history_item.dart';
import 'package:li_on/pages/roadmap/model/chat_session.dart';
import 'package:li_on/pages/roadmap/provider/roadmap_repository.dart';

final List<ChatHistoryItem> _dummyChatHistories = [
  ChatHistoryItem(
    id: 1,
    certificateName: '정보처리기사',
    title: '3개월 학습 로드맵 수립 및 필기 과목별 우선순위 정리',
    updatedAt: DateTime(2026, 7, 13),
  ),
  ChatHistoryItem(
    id: 2,
    certificateName: '정보처리기사',
    title: '실기 대비 데이터베이스 파트 집중 학습 자료 탐색',
    updatedAt: DateTime(2026, 7, 9),
  ),
  ChatHistoryItem(
    id: 3,
    certificateName: '빅데이터분석기사',
    title: '빅데이터분석기사 응시 자격 및 시험 일정 확인, 학습 계획 초안 작성',
    updatedAt: DateTime(2026, 7, 6),
  ),
  ChatHistoryItem(
    id: 4,
    certificateName: 'SQLD',
    title: 'SQLD 기출 유형 정리 및 취약 개념 복습 계획',
    updatedAt: DateTime(2026, 6, 28),
  ),
];

/// 대화 내역 목록을 가져오는 방법을 추상화한다.
/// API 연동 시에는 이 인터페이스를 구현하는 클래스를 새로 만들고
/// [chatHistoryRepositoryProvider]의 구현체만 교체하면 된다.
abstract class ChatHistoryRepository {
  Future<List<ChatHistoryItem>> fetchChatHistories();
}

/// 실제 API가 준비되기 전까지 사용하는 더미 구현체.
class DummyChatHistoryRepository implements ChatHistoryRepository {
  const DummyChatHistoryRepository();

  @override
  Future<List<ChatHistoryItem>> fetchChatHistories() async {
    return _dummyChatHistories;
  }
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
