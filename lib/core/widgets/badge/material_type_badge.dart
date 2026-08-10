import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/model/material_resource_type.dart';

/// 자료의 형태(링크·파일·메모)를 나타내는 작은 회색 배지.
/// 자료방 목록과 저장 시트 미리보기가 같은 모양을 쓰도록 한 곳에 모아둔다.
class MaterialTypeBadge extends StatelessWidget {
  final MaterialResourceType type;

  const MaterialTypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.space0),
      ),
      child: Text(
        type.label,
        style: AppTextStyle.subText.copyWith(fontSize: 10),
      ),
    );
  }
}
