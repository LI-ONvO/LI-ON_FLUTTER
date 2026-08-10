import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';

/// 캘린더 추가 시트에서 쓰는 체크박스.
/// '전체 선택'과 일정 항목 양쪽에서 같은 모양으로 쓰인다.
class SelectionCheckbox extends StatelessWidget {
  final bool selected;
  final VoidCallback? onTap;

  const SelectionCheckbox({super.key, required this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 20,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: 2,
          ),
        ),
        child: selected
            ? const Icon(Icons.check, size: 14, color: AppColors.white)
            : null,
      ),
    );
  }
}
