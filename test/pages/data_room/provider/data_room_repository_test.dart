import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/pages/data_room/model/saved_material.dart';
import 'package:li_on/pages/data_room/provider/data_room_repository.dart';

Future<SavedMaterial> addSample(
  InMemoryDataRoomRepository repository, {
  String title = '새 자료',
}) {
  return repository.addMaterial(
    title: title,
    category: '정보처리기사',
    source: '정보처리기사 로드맵 채팅',
    type: MaterialResourceType.link,
  );
}

void main() {
  test('자료를 지운 뒤에 저장해도 살아있는 자료와 id가 겹치지 않는다', () async {
    final repository = InMemoryDataRoomRepository();
    await repository.deleteMaterial('1');
    await repository.deleteMaterial('2');

    final SavedMaterial added = await addSample(repository);
    final List<SavedMaterial> materials = await repository.fetchMaterials();
    final List<String> ids = materials.map((material) => material.id).toList();

    expect(ids.toSet().length, ids.length, reason: '중복된 id가 없어야 한다');
    expect(ids, contains(added.id));
  });

  test('겹치는 id가 없으므로 한 건을 지워도 다른 자료가 함께 지워지지 않는다', () async {
    final repository = InMemoryDataRoomRepository();
    await repository.deleteMaterial('1');
    await repository.deleteMaterial('2');

    final SavedMaterial added = await addSample(repository);
    await repository.deleteMaterial(added.id);

    final List<String> ids = (await repository.fetchMaterials())
        .map((material) => material.id)
        .toList();
    expect(ids, ['3', '4']);
  });

  test('저장소를 새로 만들면 앞선 저장소의 변경이 남지 않는다', () async {
    final first = InMemoryDataRoomRepository();
    await first.deleteMaterial('1');
    await addSample(first, title: '첫 저장소에만 있는 자료');

    final List<SavedMaterial> fresh = await InMemoryDataRoomRepository()
        .fetchMaterials();
    expect(fresh.map((material) => material.id), ['1', '2', '3', '4']);
  });
}
