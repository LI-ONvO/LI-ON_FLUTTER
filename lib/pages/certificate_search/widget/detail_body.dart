import 'package:flutter/material.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/pages/certificate_search/model/certificate_detail.dart';
import 'package:li_on/pages/certificate_search/widget/header_card.dart';
import 'package:li_on/pages/certificate_search/widget/info_row.dart';
import 'package:li_on/pages/certificate_search/widget/subject_card.dart';

class CertificateDetailBody extends StatelessWidget {
  final CertificateDetail detail;

  const CertificateDetailBody({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.space3),
          CertificateHeaderCard(detail: detail),
          const SizedBox(height: AppSpacing.space5),
          Text('시험 정보', style: AppTextStyle.section),
          const SizedBox(height: AppSpacing.space1),
          CertificateInfoRow(label: '응시료', value: detail.examFee),
          CertificateInfoRow(
            label: '합격률',
            value: '${detail.passRate.toStringAsFixed(1)}%',
          ),
          CertificateInfoRow(label: '시험 시간', value: detail.examDuration),
          CertificateInfoRow(label: '과목 수', value: '${detail.subjectCount}과목'),
          const SizedBox(height: AppSpacing.space5),
          Text('시험 과목', style: AppTextStyle.section),
          const SizedBox(height: AppSpacing.space2),
          ...detail.subjects.map(
            (subject) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space2),
              child: CertificateSubjectCard(subject: subject),
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
        ],
      ),
    );
  }
}
