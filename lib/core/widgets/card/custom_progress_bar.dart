import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';

class CustomProgressBar extends StatelessWidget {
  final double? percent;

  /// false면 [percent] 값으로 바를 채우되, 옆의 퍼센트 텍스트는 그리지 않는다.
  final bool showLabel;
  final double height;

  const CustomProgressBar({
    super.key,
    this.percent,
    this.showLabel = true,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final bool showPercent = showLabel && percent != null;
    final double clampedPercent = (percent ?? 0.0).clamp(0.0, 1.0);
    final double radius = height / 2;

    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Container(
                      height: height,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(radius),
                      ),
                    ),
                    Container(
                      width: constraints.maxWidth * clampedPercent,
                      height: height,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(radius),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (showPercent) ...[
            const SizedBox(width: 10),
            Text(
              '${(clampedPercent * 100).round()}%',
              style: AppTextStyle.button.copyWith(color: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }
}
