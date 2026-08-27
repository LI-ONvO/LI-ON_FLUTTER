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

/// `GET /api/certificates` 목록의 자격증 한 건.
@JsonSerializable()
class Certificate {
  final int id;
  final String name;
  final String issuingOrg;
  final String category;

  const Certificate({
    required this.id,
    required this.name,
    required this.issuingOrg,
    required this.category,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) =>
      _$CertificateFromJson(json);

  Map<String, dynamic> toJson() => _$CertificateToJson(this);

  /// 아바타에 쓰는 이름 첫 글자. API에 없는 값이라 저장하지 않고 계산한다.
  String get initial => name.isNotEmpty ? name.substring(0, 1) : '';

  Color get accentColor => _categoryColors[category] ?? AppColors.primary;
}
