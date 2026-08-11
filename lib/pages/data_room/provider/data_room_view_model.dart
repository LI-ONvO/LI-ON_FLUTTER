import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/constants/material_category.dart';
import 'package:li_on/pages/data_room/model/saved_material.dart';
import 'package:li_on/pages/data_room/provider/data_room_repository.dart';

export 'package:li_on/core/constants/material_category.dart';
export 'package:li_on/pages/data_room/model/saved_material.dart';

/// 자료방에 저장된 자료 목록. 로드맵에서 자료를 저장하면 [add]로 들어오고,
/// 자료방 화면은 이 목록을 지켜보므로 저장 즉시 새 자료가 보인다.
class DataRoomMaterials extends AsyncNotifier<List<SavedMaterial>> {
  @override
  Future<List<SavedMaterial>> build() {
    return ref.watch(dataRoomRepositoryProvider).fetchMaterials();
  }

  Future<void> add({
    required String title,
    required String category,
    required String source,
    required MaterialResourceType type,
    String url = '',
    String memo = '',
  }) async {
    final DataRoomRepository repository = ref.read(dataRoomRepositoryProvider);
    await repository.addMaterial(
      title: title,
      category: category,
      source: source,
      type: type,
      url: url,
      memo: memo,
    );
    // 저장 결과를 화면에 직접 끼워 넣지 않고 저장소에서 다시 읽어, 목록이
    // 항상 저장소와 같은 상태가 되게 한다.
    state = AsyncData(await repository.fetchMaterials());
  }

  /// 사용자가 고친 제목·카테고리·메모를 반영한다.
  /// AsyncNotifier에 이미 update가 있어 이름을 edit으로 둔다.
  Future<void> edit({
    required String id,
    required String title,
    required String category,
    required String memo,
  }) async {
    final DataRoomRepository repository = ref.read(dataRoomRepositoryProvider);
    await repository.updateMaterial(
      id: id,
      title: title,
      category: category,
      memo: memo,
    );
    state = AsyncData(await repository.fetchMaterials());
  }

  Future<void> remove(String id) async {
    final DataRoomRepository repository = ref.read(dataRoomRepositoryProvider);
    await repository.deleteMaterial(id);
    state = AsyncData(await repository.fetchMaterials());
  }
}

final dataRoomMaterialsProvider =
    AsyncNotifierProvider<DataRoomMaterials, List<SavedMaterial>>(
      DataRoomMaterials.new,
    );

/// 사용자가 고른 필터 칩.
class DataRoomFilter extends Notifier<String> {
  @override
  String build() => allCategory;

  void select(String category) {
    state = category;
  }
}

final dataRoomFilterProvider = NotifierProvider<DataRoomFilter, String>(
  DataRoomFilter.new,
);

/// 필터 칩 목록. '전체' 뒤에 저장된 자료의 카테고리를 중복 없이 붙인다.
final dataRoomCategoriesProvider = Provider<List<String>>((ref) {
  final List<SavedMaterial> materials =
      ref.watch(dataRoomMaterialsProvider).value ?? const [];
  return [
    allCategory,
    ...{for (final material in materials) material.category},
  ];
});

/// 자료를 분류할 수 있는 카테고리. 이미 저장된 자료의 카테고리에 '기타'를
/// 더한 목록으로, 자료 수정 시트의 선택지가 된다.
final materialCategoryOptionsProvider = Provider<List<String>>((ref) {
  final List<String> options = ref
      .watch(dataRoomCategoriesProvider)
      .where((category) => category != allCategory)
      .toList();
  if (!options.contains(etcCategory)) options.add(etcCategory);
  return options;
});

/// id로 자료 한 건을 찾는다. 지워졌으면 null.
final materialByIdProvider = Provider.family<SavedMaterial?, String>((ref, id) {
  final List<SavedMaterial> materials =
      ref.watch(dataRoomMaterialsProvider).value ?? const [];
  final Iterable<SavedMaterial> matched = materials.where(
    (material) => material.id == id,
  );
  return matched.isEmpty ? null : matched.first;
});

/// 실제로 적용 중인 카테고리. 아직 자료가 없어 칩이 사라진 카테고리가 골라져
/// 있으면 '전체'로 되돌려, 목록이 빈 채로 남지 않게 한다.
final selectedDataRoomCategoryProvider = Provider<String>((ref) {
  final String selected = ref.watch(dataRoomFilterProvider);
  final List<String> categories = ref.watch(dataRoomCategoriesProvider);
  return categories.contains(selected) ? selected : allCategory;
});

/// 카테고리 필터가 적용된 자료 목록. 최근에 저장한 자료가 위로 오도록 정렬한다.
final filteredDataRoomMaterialsProvider =
    Provider<AsyncValue<List<SavedMaterial>>>((ref) {
      final String category = ref.watch(selectedDataRoomCategoryProvider);
      final AsyncValue<List<SavedMaterial>> materialsAsync = ref.watch(
        dataRoomMaterialsProvider,
      );

      return materialsAsync.whenData((materials) {
        final List<SavedMaterial> filtered = materials
            .where(
              (material) =>
                  category == allCategory || material.category == category,
            )
            .toList();
        filtered.sort((a, b) => b.savedAt.compareTo(a.savedAt));
        return filtered;
      });
    });
