import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/network/api_client.dart';
import 'package:li_on/core/network/api_exception.dart';
import 'package:li_on/features/chat/data/chat_session.dart';
import 'package:li_on/features/chat/data/chat_session_detail.dart';
import 'package:li_on/features/roadmap/data/roadmap_message_result.dart';

/// 로드맵 채팅 세션·메시지 API를 추상화한다.
abstract class RoadmapRepository {
  /// `GET /api/chat/sessions` — 과거 대화 세션 목록.
  Future<ChatSessionListResult> fetchSessions({int? page, int? size});

  /// `POST /api/chat/sessions` — 새 채팅 세션 생성.
  Future<ChatSessionCreateResult> createSession({String? jmCd, String? title});

  /// `GET /api/chat/sessions/{sessionId}` — 세션 상세(메시지 내역).
  Future<ChatSessionDetail> fetchSessionDetail(int sessionId);

  /// `POST /api/chat/sessions/{sessionId}/messages` — 메시지 전송(AI 응답).
  Future<RoadmapMessageResult> sendMessage({
    required int sessionId,
    required String content,
  });
}

class HttpRoadmapRepository implements RoadmapRepository {
  HttpRoadmapRepository(this.apiClient);

  final ApiClient apiClient;

  @override
  Future<ChatSessionListResult> fetchSessions({int? page, int? size}) {
    return guardApiCall(() async {
      final response = await apiClient.dio.get(
        '/api/chat/sessions',
        queryParameters: {'page': ?page, 'size': ?size},
      );
      return ChatSessionListResult.fromJson(response.data);
    });
  }

  @override
  Future<ChatSessionCreateResult> createSession({String? jmCd, String? title}) {
    return guardApiCall(() async {
      final response = await apiClient.dio.post(
        '/api/chat/sessions',
        data: {'jmCd': ?jmCd, 'title': ?title},
      );
      return ChatSessionCreateResult.fromJson(response.data);
    });
  }

  @override
  Future<ChatSessionDetail> fetchSessionDetail(int sessionId) {
    return guardApiCall(() async {
      final response = await apiClient.dio.get('/api/chat/sessions/$sessionId');
      return ChatSessionDetail.fromJson(response.data);
    });
  }

  @override
  Future<RoadmapMessageResult> sendMessage({
    required int sessionId,
    required String content,
  }) {
    return guardApiCall(() async {
      final response = await apiClient.dio.post(
        '/api/chat/sessions/$sessionId/messages',
        data: {'content': content},
      );
      return RoadmapMessageResult.fromJson(response.data);
    });
  }
}

final roadmapRepositoryProvider = Provider<RoadmapRepository>((ref) {
  return HttpRoadmapRepository(ref.watch(apiClientProvider));
});
