import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/pages/certificate_search/model/certificate_detail.dart';

class CertificateHeaderCard extends StatelessWidget {
  final CertificateDetail detail;

  const CertificateHeaderCard({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(AppSpacing.space3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.name,
            style: AppTextStyle.baseTextStyle.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: AppSpacing.space0),
          Text(detail.issuingOrg, style: AppTextStyle.mainText),
          const SizedBox(height: AppSpacing.space1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              detail.level,
              style: AppTextStyle.baseTextStyle.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.dark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
