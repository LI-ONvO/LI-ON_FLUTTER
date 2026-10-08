import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';

class CertificateInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const CertificateInfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 45),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space1),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyle.mainText),
          const SizedBox(width: AppSpacing.space2),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyle.baseTextStyle.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
