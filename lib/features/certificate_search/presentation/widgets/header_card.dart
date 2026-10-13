import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/features/certificate_search/data/certificate.dart';
import 'package:li_on/features/certificate_search/data/certificate_detail.dart';

class CertificateHeaderCard extends StatelessWidget {
  final CertificateDetail detail;

  const CertificateHeaderCard({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final List<String> tags = [
      detail.category,
      qualGbLabel(detail.qualGbCd),
    ].where((tag) => tag.isNotEmpty).toList();

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
          if (tags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space1),
            Wrap(
              spacing: AppSpacing.space1,
              runSpacing: AppSpacing.space1,
              children: [for (final tag in tags) _Tag(tag)],
            ),
          ],
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyle.baseTextStyle.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: AppColors.dark,
        ),
      ),
    );
  }
}
