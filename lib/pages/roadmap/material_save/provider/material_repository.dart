import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/constants/material_category.dart';
import 'package:li_on/pages/roadmap/material_save/model/material_resource.dart';

/// 로드맵 대화에서 추천받은 자료 더미 데이터.
/// 실제로는 대화 내용을 분석한 결과가 내려온다.
MaterialResource _dummyResource(String certificateName) {
  return MaterialResource(
    id: '1',
    title: '$certificateName 필기 기출문제 모음',
    url: 'exam-archive.kr/info-processing-2026',
    type: MaterialResourceType.link,
  );
}

/// 저장 시트가 채워 넣을 추천 자료와 카테고리를 가져오는 방법을 추상화한다.
/// 실제 저장은 자료방 쪽 저장소(dataRoomRepositoryProvider)가 맡는다.
/// API 연동 시에는 이 인터페이스를 구현하는 클래스를 새로 만들고
/// [materialRepositoryProvider]의 구현체만 교체하면 된다.
abstract class MaterialRepository {
  /// 해당 자격증의 로드맵 대화에서 추천된 자료.
  Future<MaterialResource> fetchSuggestedResource(String certificateName);

  /// 자료를 분류할 수 있는 카테고리 목록.
  Future<List<String>> fetchCategories(String certificateName);
}

/// 실제 자료방 API가 준비되기 전까지 사용하는 더미 구현체.
class DummyMaterialRepository implements MaterialRepository {
  const DummyMaterialRepository();

  @override
  Future<MaterialResource> fetchSuggestedResource(
    String certificateName,
  ) async {
    return _dummyResource(certificateName);
  }

  @override
  Future<List<String>> fetchCategories(String certificateName) async {
    return [certificateName, etcCategory];
  }
}

final materialRepositoryProvider = Provider<MaterialRepository>((ref) {
  return const DummyMaterialRepository();
});

/// 자료방 저장 시트에 필요한 자료와 카테고리 목록.
typedef MaterialSaveData = ({
  MaterialResource resource,
  List<String> categories,
});

final materialSaveDataProvider = FutureProvider.autoDispose
    .family<MaterialSaveData, String>((ref, certificateName) async {
      final MaterialRepository repository = ref.watch(
        materialRepositoryProvider,
      );
      final (resource, categories) = await (
        repository.fetchSuggestedResource(certificateName),
        repository.fetchCategories(certificateName),
      ).wait;
      return (resource: resource, categories: categories);
    });
