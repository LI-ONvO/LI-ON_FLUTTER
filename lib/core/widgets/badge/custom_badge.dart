import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';

class CustomBadge extends StatelessWidget {
  final String field;
  final bool selected;
  final VoidCallback? onTap;

  /// Solid pill style used for filter chips (e.g. category filters),
  /// as opposed to the default outlined style used for multi-select fields.
  final bool filled;

  /// 아웃라인 스타일을 필터 칩과 같은 높이(32)로 줄인다.
  /// 바텀시트처럼 공간이 좁은 곳에서 사용한다. [filled]에는 영향이 없다.
  final bool compact;

  const CustomBadge({
    super.key,
    required this.field,
    this.selected = false,
    this.onTap,
    this.filled = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (filled) {
      final Color backgroundColor = selected
          ? AppColors.primary
          : AppColors.background;
      final Color textColor = selected ? AppColors.white : AppColors.heading;
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 32,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppSpacing.space3),
          ),
          child: Text(
            field,
            style: AppTextStyle.mainText.copyWith(
              fontSize: 13,
              color: textColor,
            ),
          ),
        ),
      );
    }

    final Color borderColor = selected ? AppColors.primary : AppColors.border;
    final Color backgroundColor = selected
        ? AppColors.light
        : AppColors.surface;
    final Color textColor = selected ? AppColors.primary : AppColors.heading;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: compact ? 32 : null,
        alignment: compact ? Alignment.center : null,
        padding: compact
            ? const EdgeInsets.symmetric(horizontal: 15)
            : const EdgeInsets.fromLTRB(17, 12, 17, 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(
            compact ? AppSpacing.space3 : AppSpacing.space4,
          ),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          field,
          style: AppTextStyle.mainText.copyWith(
            fontSize: compact ? 13 : null,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
