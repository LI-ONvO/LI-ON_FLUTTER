import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';

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
      height: 45,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyle.mainText),
          Text(value, style: AppTextStyle.baseTextStyle.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}
