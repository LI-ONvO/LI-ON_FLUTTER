import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/constants/material_category.dart';
import 'package:li_on/core/network/api_client.dart';
import 'package:li_on/core/network/api_exception.dart';
import 'package:li_on/features/data_room/data/resource_recommendation.dart';
import 'package:li_on/features/data_room/data/resource_response.dart';
import 'package:li_on/features/data_room/data/saved_material.dart';

/// 자료방에 저장된 자료를 읽고 쓰는 방법을 추상화한다.
abstract class DataRoomRepository {
  Future<List<SavedMaterial>> fetchMaterials();

  /// 자료를 저장하고, id가 부여된 자료를 돌려준다.
  /// [sessionId]·[jmCd]는 로드맵 채팅에서 저장할 때 함께 넘어온다.
  Future<SavedMaterial> addMaterial({
    required String title,
    required String category,
    required String source,
    required MaterialResourceType type,
    String url,
    String memo,
    int? sessionId,
    String? jmCd,
  });

  /// `POST /api/resources/recommendations` — 이 자격증·세션에 맞는 학습
  /// 자료를 AI가 추천한다. 이미 아카이빙한 자료는 서버가 제외하고 준다.
  Future<ResourceRecommendationResult> fetchRecommendations({
    required String jmCd,
    required int sessionId,
    int size,
  });

  /// 사용자가 고칠 수 있는 항목(제목·카테고리·메모)만 바꾼다.
  /// 저장 시각·출처·주소는 그대로 둔다.
  Future<SavedMaterial> updateMaterial({
    required int id,
    required String title,
    required String category,
    required String memo,
  });

  Future<void> deleteMaterial(int id);
}

/// 저장한 자료를 들고 있는 저장소. 로드맵에서 저장한 자료가 자료방 탭에
/// 그대로 보이려면 앱 전체가 같은 인스턴스를 공유해야 하므로 유지형
/// [Provider]로 둔다.
final dataRoomRepositoryProvider = Provider<DataRoomRepository>((ref) {
  return HttpDataRoomRepository(ref.watch(apiClientProvider));
});

/// `/api/resources` CRUD를 쓰는 실제 구현체.
/// 서버에는 카테고리·출처 개념이 없어 연관 자격증(`certificate.name`)을
/// 카테고리로, 출처 세션(`session.title`)을 출처 문구로 옮겨 담는다.
class HttpDataRoomRepository implements DataRoomRepository {
  HttpDataRoomRepository(this.apiClient);

  final ApiClient apiClient;

  Future<ResourceDetail> _fetchDetail(int id) async {
    final response = await apiClient.dio.get('/api/resources/$id');
    return ResourceDetail.fromJson(response.data);
  }

  SavedMaterial _toSavedMaterial(ResourceDetail detail) {
    return SavedMaterial(
      id: detail.id,
      title: detail.title,
      category: detail.certificate?.name ?? etcCategory,
      source: detail.session?.title ?? '',
      type: detail.type,
      url: detail.url,
      memo: detail.memo,
      savedAt: detail.createdAt,
    );
  }

  @override
  Future<List<SavedMaterial>> fetchMaterials() {
    return guardApiCall(() async {
      final response = await apiClient.dio.get(
        '/api/resources',
        queryParameters: {'page': 0, 'size': 100},
      );
      final ResourcePageResult page = ResourcePageResult.fromJson(
        response.data,
      );
      // 목록 응답에는 카테고리(자격증 이름)·출처·메모가 없어, 상세를 병렬
      // 조회해 화면 모델을 채운다.
      final List<ResourceDetail> details = await Future.wait(
        page.content.map((item) => _fetchDetail(item.id)),
      );
      return details.map(_toSavedMaterial).toList();
    });
  }

  @override
  Future<SavedMaterial> addMaterial({
    required String title,
    required String category,
    required String source,
    required MaterialResourceType type,
    String url = '',
    String memo = '',
    int? sessionId,
    String? jmCd,
  }) {
    return guardApiCall(() async {
      final response = await apiClient.dio.post(
        '/api/resources',
        data: {
          'title': title,
          'url': url,
          if (memo.isNotEmpty) 'memo': memo,
          'sessionId': ?sessionId,
          'jmCd': ?jmCd,
        },
      );
      final ResourceCreateResult created = ResourceCreateResult.fromJson(
        response.data,
      );
      // 카테고리·출처·타입은 서버 응답 필드가 아니라 화면에서 넘어온 값을 유지한다.
      return SavedMaterial(
        id: created.id,
        title: created.title,
        category: category,
        source: source,
        type: type,
        url: created.url,
        memo: created.memo,
        savedAt: created.createdAt,
      );
    });
  }

  @override
  Future<SavedMaterial> updateMaterial({
    required int id,
    required String title,
    required String category,
    required String memo,
  }) {
    return guardApiCall(() async {
      await apiClient.dio.patch(
        '/api/resources/$id',
        data: {'title': title, 'memo': memo},
      );
      final ResourceDetail detail = await _fetchDetail(id);
      final SavedMaterial updated = _toSavedMaterial(detail);
      return SavedMaterial(
        id: updated.id,
        title: updated.title,
        category: category,
        source: updated.source,
        type: updated.type,
        url: updated.url,
        memo: updated.memo,
        savedAt: updated.savedAt,
      );
    });
  }

  @override
  Future<void> deleteMaterial(int id) {
    return guardApiCall(() async {
      await apiClient.dio.delete('/api/resources/$id');
    });
  }

  @override
  Future<ResourceRecommendationResult> fetchRecommendations({
    required String jmCd,
    required int sessionId,
    int size = 5,
  }) {
    return guardApiCall(() async {
      final response = await apiClient.dio.post(
        '/api/resources/recommendations',
        data: {'jmCd': jmCd, 'sessionId': sessionId, 'size': size},
      );
      return ResourceRecommendationResult.fromJson(response.data);
    });
  }
}
