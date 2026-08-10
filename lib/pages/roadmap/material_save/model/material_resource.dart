import 'package:json_annotation/json_annotation.dart';
import 'package:li_on/core/model/material_resource_type.dart';

// 자료 형태는 자료방 목록에서도 쓰므로 core로 옮겼다. 이 모델을 쓰는 쪽이
// 형태까지 함께 받을 수 있도록 다시 내보낸다.
export 'package:li_on/core/model/material_resource_type.dart';

part 'material_resource.g.dart';

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
