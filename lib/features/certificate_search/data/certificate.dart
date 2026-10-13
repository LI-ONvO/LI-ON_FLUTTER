import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:li_on/core/constants/color.dart';

part 'certificate.g.dart';

const String allCategory = '전체';

/// 칩으로 따로 보여주지 않는 category(드문 전문자격 이름, 빈 값)를 묶는 칩.
const String otherCategory = '기타';

const Map<String, Color> _categoryColors = {
  'IT': Color(0xFF2563EB),
  '경영': Color(0xFFD97706),
  '건축': Color(0xFF059669),
  '보건': Color(0xFFDB2777),
  '교육': Color(0xFF7C3AED),
};

/// 자격구분코드(`qualGbCd`)의 한글 이름. 같은 종목도 취득 방법에 따라
/// 국가기술자격·과정평가형자격으로 따로 내려오므로 화면에서 구분해 보여준다.
/// 모르는 코드나 빈 값(서버가 아직 안 내려주는 경우 포함)은 빈 문자열.
const Map<String, String> _qualGbNames = {
  'T': '국가기술자격',
  'S': '국가전문자격',
  'W': '일학습병행자격',
  'C': '과정평가형자격',
};

String qualGbLabel(String qualGbCd) => _qualGbNames[qualGbCd] ?? '';

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
/// 처럼 숫자로만 이뤄지지 않을 수 있음)로 내려준다. 실제 응답:
/// `{jmCd, name, category, qualGbCd}`.
@JsonSerializable()
class Certificate {
  @JsonKey(name: 'jmCd')
  final String id;

  final String name;

  @JsonKey(defaultValue: '')
  final String category;

  /// 자격구분코드(T·S·W·C). 값 의미는 [qualGbLabel] 참고.
  @JsonKey(defaultValue: '')
  final String qualGbCd;

  const Certificate({
    required this.id,
    required this.name,
    required this.category,
    this.qualGbCd = '',
  });

  factory Certificate.fromJson(Map<String, dynamic> json) =>
      _$CertificateFromJson(json);

  Map<String, dynamic> toJson() => _$CertificateToJson(this);

  /// 아바타에 쓰는 이름 첫 글자. API에 없는 값이라 저장하지 않고 계산한다.
  String get initial => name.isNotEmpty ? name.substring(0, 1) : '';

  Color get accentColor => _categoryColors[category] ?? AppColors.primary;

  /// 목록 카드의 부제. 분류와 자격구분을 "기능사 · 과정평가형자격"처럼 잇는다.
  String get subtitle => [
    category,
    qualGbLabel(qualGbCd),
  ].where((part) => part.isNotEmpty).join(' · ');
}
