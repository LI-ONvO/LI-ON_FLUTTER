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

  const CustomBadge({
    super.key,
    required this.field,
    this.selected = false,
    this.onTap,
    this.filled = false,
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
        padding: const EdgeInsets.fromLTRB(17, 12, 17, 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.space4),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          field,
          style: AppTextStyle.mainText.copyWith(color: textColor),
        ),
      ),
    );
  }
}
