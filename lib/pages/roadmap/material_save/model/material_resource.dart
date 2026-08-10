import 'package:json_annotation/json_annotation.dart';

part 'material_resource.g.dart';

/// 자료의 형태. 카드 오른쪽 배지로 노출된다.
enum MaterialResourceType { link, file, note }

extension MaterialResourceTypeLabel on MaterialResourceType {
  String get label => switch (this) {
    MaterialResourceType.link => '링크',
    MaterialResourceType.file => '파일',
    MaterialResourceType.note => '메모',
  };
}

/// 로드맵 대화에서 추천받아 자료방에 저장할 수 있는 자료 한 건.
@JsonSerializable()
class MaterialResource {
  final String id;

  final String title;

  /// 자료의 주소. [MaterialResourceType.note]처럼 주소가 없는 자료면 비어 있다.
  final String url;

  final MaterialResourceType type;

  const MaterialResource({
    required this.id,
    required this.title,
    this.url = '',
    this.type = MaterialResourceType.link,
  });

  factory MaterialResource.fromJson(Map<String, dynamic> json) =>
      _$MaterialResourceFromJson(json);

  Map<String, dynamic> toJson() => _$MaterialResourceToJson(this);

  bool get hasUrl => url.isNotEmpty;
}
