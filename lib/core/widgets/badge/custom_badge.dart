import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';

class CustomBadge extends StatelessWidget {
  final String field;
  final bool selected;
  final VoidCallback? onTap;

  const CustomBadge({
    super.key,
    required this.field,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = selected ? AppColors.primary : AppColors.border;
    final Color backgroundColor = selected ? AppColors.light : AppColors.surface;
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
