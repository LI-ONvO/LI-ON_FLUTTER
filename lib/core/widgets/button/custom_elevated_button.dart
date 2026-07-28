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
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.space3,
            horizontal: AppSpacing.space4,
          ),
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.space2),
          ),
          elevation: 0,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.black.withValues(alpha: 0.16);
            }
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)) {
              return Colors.black.withValues(alpha: 0.08);
            }
            return null;
          }),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: AppTextStyle.section.copyWith(color: resolvedForegroundColor),
        ),
      ),
    );
  }
}
