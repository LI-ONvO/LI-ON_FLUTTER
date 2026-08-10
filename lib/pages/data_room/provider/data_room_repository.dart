import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/pages/data_room/model/saved_material.dart';

/// 자료방을 처음 열었을 때 보이는 더미 데이터.
/// 실제로는 서버에 저장해둔 자료 목록이 내려온다.
List<SavedMaterial> _dummyMaterials() => [
  SavedMaterial(
    id: '1',
    title: '필기 핵심요약 PDF',
    category: '정보처리기사',
    source: '정보처리기사 로드맵 채팅',
    type: MaterialResourceType.file,
    savedAt: DateTime(2026, 7, 12),
  ),
  SavedMaterial(
    id: '2',
    title: '기출문제 정리 링크',
    category: '정보처리기사',
    source: '정보처리기사 로드맵 채팅',
    url: 'exam-archive.kr/info-processing-2026',
    savedAt: DateTime(2026, 7, 10),
  ),
  SavedMaterial(
    id: '3',
    title: '학습 계획 메모',
    category: '정보처리기사',
    source: '정보처리기사 로드맵 채팅',
    type: MaterialResourceType.note,
    savedAt: DateTime(2026, 7, 8),
  ),
  SavedMaterial(
    id: '4',
    title: '빅데이터 분석 개념 정리',
    category: '빅데이터분석기사',
    source: '빅데이터분석기사 로드맵 채팅',
    type: MaterialResourceType.note,
    savedAt: DateTime(2026, 7, 5),
  ),
];

/// 자료방에 저장된 자료를 읽고 쓰는 방법을 추상화한다.
/// API 연동 시에는 이 인터페이스를 구현하는 클래스를 새로 만들고
/// [dataRoomRepositoryProvider]의 구현체만 교체하면 된다.
abstract class DataRoomRepository {
  Future<List<SavedMaterial>> fetchMaterials();

  /// 자료를 저장하고, id가 부여된 자료를 돌려준다.
  Future<SavedMaterial> addMaterial({
    required String title,
    required String category,
    required String source,
    required MaterialResourceType type,
    String url,
    String memo,
  });

  /// 사용자가 고칠 수 있는 항목(제목·카테고리·메모)만 바꾼다.
  /// 저장 시각·출처·주소는 그대로 둔다.
  Future<SavedMaterial> updateMaterial({
    required String id,
    required String title,
    required String category,
    required String memo,
  });

  Future<void> deleteMaterial(String id);
}

/// 실제 자료방 API가 준비되기 전까지 사용하는 메모리 저장소.
/// 앱이 떠 있는 동안에만 유지되므로, 다시 실행하면 더미 데이터로 돌아간다.
class InMemoryDataRoomRepository implements DataRoomRepository {
  final List<SavedMaterial> _materials = _dummyMaterials();

  /// 새로 저장하는 자료에 붙일 id. 더미 데이터의 id와 겹치지 않게 이어서 센다.
  late int _nextId = _materials.length + 1;

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
  }) async {
    final SavedMaterial material = SavedMaterial(
      id: '${_nextId++}',
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
    required String id,
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
  Future<void> deleteMaterial(String id) async {
    _materials.removeWhere((material) => material.id == id);
  }
}

/// 저장한 자료를 들고 있는 저장소. 로드맵에서 저장한 자료가 자료방 탭에
/// 그대로 보이려면 앱 전체가 같은 인스턴스를 공유해야 하므로 유지형
/// [Provider]로 둔다.
final dataRoomRepositoryProvider = Provider<DataRoomRepository>((ref) {
  return InMemoryDataRoomRepository();
});
