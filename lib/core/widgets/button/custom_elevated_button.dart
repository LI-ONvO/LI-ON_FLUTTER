import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';

class CustomElevatedButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;

  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.backgroundColor,
    this.foregroundColor = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null;
    final Color resolvedBackgroundColor = isDisabled
        ? backgroundColor.withValues(alpha: 0.4)
        : backgroundColor;
    final Color resolvedForegroundColor = isDisabled
        ? foregroundColor.withValues(alpha: 0.6)
        : foregroundColor;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: resolvedBackgroundColor,
          disabledBackgroundColor: resolvedBackgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.space2),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: AppTextStyle.button.copyWith(color: resolvedForegroundColor),
        ),
      ),
    );
  }
}
