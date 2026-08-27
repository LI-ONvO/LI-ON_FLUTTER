import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/network/api_client.dart';
import 'package:li_on/core/network/api_exception.dart';
import 'package:li_on/pages/roadmap/model/chat_session.dart';
import 'package:li_on/pages/roadmap/model/chat_session_detail.dart';
import 'package:li_on/pages/roadmap/model/roadmap_detail.dart';
import 'package:li_on/pages/roadmap/model/roadmap_message_result.dart';
import 'package:li_on/pages/roadmap/model/roadmap_summary.dart';

/// 로드맵 채팅 세션·메시지·로드맵 API를 추상화한다.
abstract class RoadmapRepository {
  /// `GET /api/chat/sessions` — 과거 대화 세션 목록.
  Future<ChatSessionListResult> fetchSessions({int? page, int? size});

  /// `POST /api/chat/sessions` — 새 채팅 세션 생성.
  Future<ChatSessionCreateResult> createSession({
    int? certificateId,
    String? title,
  });

  /// `GET /api/chat/sessions/{sessionId}` — 세션 상세(메시지 내역).
  Future<ChatSessionDetail> fetchSessionDetail(int sessionId);

  /// `POST /api/chat/sessions/{sessionId}/messages` — 메시지 전송(AI 응답).
  Future<RoadmapMessageResult> sendMessage({
    required int sessionId,
    required String content,
  });

  /// `POST /api/chat/sessions/{sessionId}/roadmaps` — 로드맵 수립/확정.
  Future<RoadmapDetail> createRoadmap({required int sessionId, String? title});

  /// `GET /api/chat/sessions/{sessionId}/roadmaps` — 세션 내 로드맵 목록.
  Future<List<RoadmapSummary>> fetchRoadmaps(int sessionId);

  /// `GET /api/roadmaps/{roadmapId}` — 로드맵 상세(스텝 포함).
  Future<RoadmapDetail> fetchRoadmapDetail(int roadmapId);
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
  Future<ChatSessionCreateResult> createSession({
    int? certificateId,
    String? title,
  }) {
    return guardApiCall(() async {
      final response = await apiClient.dio.post(
        '/api/chat/sessions',
        data: {'certificateId': ?certificateId, 'title': ?title},
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

  @override
  Future<RoadmapDetail> createRoadmap({required int sessionId, String? title}) {
    return guardApiCall(() async {
      final response = await apiClient.dio.post(
        '/api/chat/sessions/$sessionId/roadmaps',
        data: {'title': ?title},
      );
      return RoadmapDetail.fromJson(response.data);
    });
  }

  @override
  Future<List<RoadmapSummary>> fetchRoadmaps(int sessionId) {
    return guardApiCall(() async {
      final response = await apiClient.dio.get(
        '/api/chat/sessions/$sessionId/roadmaps',
      );
      return (response.data as List)
          .map((json) => RoadmapSummary.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<RoadmapDetail> fetchRoadmapDetail(int roadmapId) {
    return guardApiCall(() async {
      final response = await apiClient.dio.get('/api/roadmaps/$roadmapId');
      return RoadmapDetail.fromJson(response.data);
    });
  }
}

final roadmapRepositoryProvider = Provider<RoadmapRepository>((ref) {
  return HttpRoadmapRepository(ref.watch(apiClientProvider));
});
