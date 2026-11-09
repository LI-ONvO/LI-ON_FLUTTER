import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/network/api_client.dart';
import 'package:li_on/core/network/api_exception.dart';
import 'package:li_on/features/chat/data/chat_session.dart';
import 'package:li_on/features/chat/data/chat_session_detail.dart';
import 'package:li_on/features/roadmap/data/roadmap_detail.dart';
import 'package:li_on/features/roadmap/data/roadmap_message_result.dart';
import 'package:li_on/features/roadmap/data/roadmap_summary.dart';

/// 로드맵 채팅 세션·메시지·로드맵 API를 추상화한다.
abstract class RoadmapRepository {
  /// `GET /api/chat/sessions` — 과거 대화 세션 목록.
  Future<ChatSessionListResult> fetchSessions({int? page, int? size});

  /// `POST /api/chat/sessions` — 새 채팅 세션 생성.
  Future<ChatSessionCreateResult> createSession({String? jmCd, String? title});

  /// `GET /api/chat/sessions/{sessionId}` — 세션 상세(메시지 내역).
  Future<ChatSessionDetail> fetchSessionDetail(int sessionId);

  /// `POST /api/chat/sessions/{sessionId}/certificates` — 자격증이 연결되지
  /// 않은 세션에 자격증을 연결한다.
  Future<void> selectSessionCertificate({
    required int sessionId,
    required String jmCd,
  });

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

  /// 로드맵 생성은 백엔드가 AI 서버 응답까지 기다려 기본 타임아웃(10초)보다
  /// 오래 걸린다. 앱이 먼저 끊으면 서버에서는 생성이 이어져 재시도 시 로드맵이
  /// 중복될 수 있어 넉넉히 둔다.
  static const Duration _createRoadmapTimeout = Duration(seconds: 60);

  /// 채팅 답변도 백엔드가 AI 서버 응답까지 기다리므로 기본 타임아웃(10초)으로는
  /// 긴 답변이 중간에 끊겨 "서버 응답이 늦어지고 있어요"가 뜬다.
  static const Duration _sendMessageTimeout = Duration(seconds: 60);

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
  Future<void> selectSessionCertificate({
    required int sessionId,
    required String jmCd,
  }) {
    return guardApiCall(() async {
      await apiClient.dio.post(
        '/api/chat/sessions/$sessionId/certificates',
        data: {'jmCd': jmCd},
      );
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
        options: Options(receiveTimeout: _sendMessageTimeout),
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
        options: Options(receiveTimeout: _createRoadmapTimeout),
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
