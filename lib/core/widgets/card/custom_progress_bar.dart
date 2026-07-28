import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';

class CustomProgressBar extends StatelessWidget {
  final double? percent;

  const CustomProgressBar({super.key, this.percent});

  @override
  Widget build(BuildContext context) {
    final bool showPercent = percent != null;
    final double clampedPercent = (percent ?? 0.0).clamp(0.0, 1.0);

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
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: constraints.maxWidth * clampedPercent,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
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
