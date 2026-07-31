import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/card/custom_progress_bar.dart';
import 'package:li_on/pages/certificate_search/model/certificate_detail.dart';

class CertificateSubjectCard extends StatelessWidget {
  final ExamSubject subject;

  const CertificateSubjectCard({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(AppSpacing.space2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subject.name,
                style: AppTextStyle.baseTextStyle.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                '${(subject.percent * 100).round()}%',
                style: AppTextStyle.mainText,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space1),
          CustomProgressBar(
            percent: subject.percent,
            showLabel: false,
            height: 6,
          ),
        ],
      ),
    );
  }
}
