import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:li_on/core/constants/color.dart';

part 'certificate.g.dart';

const String allCategory = '전체';

const List<String> certificateCategories = [
  allCategory,
  'IT',
  '경영',
  '건축',
  '보건',
  '교육',
];

const Map<String, Color> _categoryColors = {
  'IT': Color(0xFF2563EB),
  '경영': Color(0xFFD97706),
  '건축': Color(0xFF059669),
  '보건': Color(0xFFDB2777),
  '교육': Color(0xFF7C3AED),
};

/// 다른 응답(채팅 세션·자료 상세 등)에 박혀 오는 자격증 요약(`{ jmCd, name }`).
@JsonSerializable()
class CertificateRef {
  final String jmCd;
  final String name;

  const CertificateRef({required this.jmCd, required this.name});

  factory CertificateRef.fromJson(Map<String, dynamic> json) =>
      _$CertificateRefFromJson(json);

  Map<String, dynamic> toJson() => _$CertificateRefToJson(this);
}

/// `GET /api/certificates` 목록의 자격증 한 건.
///
/// 서버는 식별자를 `id`가 아니라 `jmCd`(HRD-Net 종목코드, 예: "C177"·"S2I0"
/// 처럼 숫자로만 이뤄지지 않을 수 있음)로 내려준다. 실제 응답: `{jmCd, name, category}`.
@JsonSerializable()
class Certificate {
  @JsonKey(name: 'jmCd')
  final String id;

  final String name;

  final String category;

  const Certificate({
    required this.id,
    required this.name,
    required this.category,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) =>
      _$CertificateFromJson(json);

  Map<String, dynamic> toJson() => _$CertificateToJson(this);

  /// 아바타에 쓰는 이름 첫 글자. API에 없는 값이라 저장하지 않고 계산한다.
  String get initial => name.isNotEmpty ? name.substring(0, 1) : '';

  Color get accentColor => _categoryColors[category] ?? AppColors.primary;
}
