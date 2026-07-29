import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';

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

class Certificate {
  final String id;
  final String initial;
  final String name;
  final String category;

  const Certificate({
    required this.id,
    required this.initial,
    required this.name,
    required this.category,
  });

  Color get accentColor => _categoryColors[category] ?? AppColors.primary;
}
