import 'package:li_on/features/data_room/data/data_room_repository.dart';
import 'package:li_on/features/data_room/data/saved_material.dart';
import 'package:li_on/features/data_room/data/resource_recommendation.dart';

/// 테스트에서 [InMemoryDataRoomRepository]의 초기 상태로 쓰는 자료 목록.
final List<SavedMaterial> _dummyMaterials = [
  SavedMaterial(
    id: 1,
    title: '필기 핵심요약 PDF',
    category: '정보처리기사',
    source: '정보처리기사 로드맵 채팅',
    type: MaterialResourceType.file,
    savedAt: DateTime(2026, 7, 12),
  ),
  SavedMaterial(
    id: 2,
    title: '기출문제 정리 링크',
    category: '정보처리기사',
    source: '정보처리기사 로드맵 채팅',
    url: 'exam-archive.kr/info-processing-2026',
    savedAt: DateTime(2026, 7, 10),
  ),
  SavedMaterial(
    id: 3,
    title: '학습 계획 메모',
    category: '정보처리기사',
    source: '정보처리기사 로드맵 채팅',
    type: MaterialResourceType.note,
    savedAt: DateTime(2026, 7, 8),
  ),
  SavedMaterial(
    id: 4,
    title: '빅데이터 분석 개념 정리',
    category: '빅데이터분석기사',
    source: '빅데이터분석기사 로드맵 채팅',
    type: MaterialResourceType.note,
    savedAt: DateTime(2026, 7, 5),
  ),
];

/// 네트워크 없이 테스트할 때 [dataRoomRepositoryProvider]에 덮어씌우는
/// 메모리 저장소. 프로덕션에서는 쓰지 않는다.
class InMemoryDataRoomRepository implements DataRoomRepository {
  /// 더미 목록을 그대로 쓰지 않고 복사해, 저장소를 새로 만들 때마다 같은
  /// 자료로 시작하게 한다.
  final List<SavedMaterial> _materials = [..._dummyMaterials];

  /// 새로 저장하는 자료에 붙일 id. 저장소를 만들 때 한 번만 정하고 이후로는
  /// 늘리기만 한다. 저장할 때마다 목록 길이로 다시 계산하면, 자료를 지운
  /// 뒤에 저장할 때 아직 쓰고 있는 id를 다시 발급하게 된다.
  int _nextId = _dummyMaterials.length + 1;

  @override
  Future<List<SavedMaterial>> fetchMaterials() async {
    // 저장소 밖에서 목록을 직접 바꾸지 못하도록 복사본을 준다.
    return List.unmodifiable(_materials);
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
  }) async {
    final SavedMaterial material = SavedMaterial(
      id: _nextId++,
      title: title,
      category: category,
      source: source,
      type: type,
      url: url,
      memo: memo,
      savedAt: DateTime.now(),
    );
    _materials.add(material);
    return material;
  }

  @override
  Future<SavedMaterial> updateMaterial({
    required int id,
    required String title,
    required String category,
    required String memo,
  }) async {
    final int index = _materials.indexWhere((material) => material.id == id);
    if (index < 0) {
      throw StateError('수정할 자료를 찾지 못했습니다: $id');
    }
    final SavedMaterial current = _materials[index];
    final SavedMaterial updated = SavedMaterial(
      id: current.id,
      title: title,
      category: category,
      source: current.source,
      type: current.type,
      url: current.url,
      memo: memo,
      savedAt: current.savedAt,
    );
    _materials[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteMaterial(int id) async {
    _materials.removeWhere((material) => material.id == id);
  }

  @override
  Future<ResourceRecommendationResult> fetchRecommendations({
    required String jmCd,
    required int sessionId,
    int size = 5,
  }) async {
    return ResourceRecommendationResult(
      jmCd: jmCd,
      generatedAt: DateTime.now(),
      items: const [
        ResourceRecommendationItem(
          title: '기출문제 해설 영상',
          url: 'https://example.com/video/mock',
          reason: '테스트용 더미 추천입니다.',
        ),
      ],
    );
  }
}
