import 'package:json_annotation/json_annotation.dart';
import 'package:li_on/core/model/material_resource_type.dart';

export 'package:li_on/core/model/material_resource_type.dart';

part 'saved_material.g.dart';

/// 자료방에 저장된 자료 한 건.
@JsonSerializable()
class SavedMaterial {
  final String id;

  /// 저장할 때 사용자가 직접 정한 제목.
  final String title;

  /// 자료를 묶는 분류. 자격증 이름이거나 '기타'이며, 목록 위쪽 필터 칩이 된다.
  final String category;

  /// 자료를 어디서 저장했는지 알려주는 문구. 예: '정보처리기사 로드맵 채팅'.
  final String source;

  final MaterialResourceType type;

  /// 자료의 주소. [MaterialResourceType.note]처럼 주소가 없는 자료면 비어 있다.
  final String url;

  final String memo;

  final DateTime savedAt;

  const SavedMaterial({
    required this.id,
    required this.title,
    required this.category,
    required this.source,
    required this.savedAt,
    this.type = MaterialResourceType.link,
    this.url = '',
    this.memo = '',
  });

  factory SavedMaterial.fromJson(Map<String, dynamic> json) =>
      _$SavedMaterialFromJson(json);

  Map<String, dynamic> toJson() => _$SavedMaterialToJson(this);

  /// "7/12" 형식의 날짜 표기. intl 의존성이 없어 직접 포맷한다.
  String get savedAtLabel => '${savedAt.month}/${savedAt.day}';

  /// "2025.07.15" 형식의 날짜 표기. 상세 화면에서 쓴다.
  String get savedAtDateLabel {
    final String month = savedAt.month.toString().padLeft(2, '0');
    final String day = savedAt.day.toString().padLeft(2, '0');
    return '${savedAt.year}.$month.$day';
  }

  bool get hasUrl => url.isNotEmpty;
}
