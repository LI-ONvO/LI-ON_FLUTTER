import 'package:flutter/material.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/badge/custom_badge.dart';
import 'package:li_on/pages/certificate_search/model/certificate_detail.dart';
import 'package:li_on/pages/certificate_search/widget/exam_schedule_card.dart';
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
          if (detail.fields.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space3),
            Wrap(
              spacing: AppSpacing.space1,
              runSpacing: AppSpacing.space1,
              children: [
                for (final field in detail.fields)
                  CustomBadge(field: field.name, compact: true),
              ],
            ),
          ],
          if (detail.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space5),
            Text('자격증 소개', style: AppTextStyle.section),
            const SizedBox(height: AppSpacing.space1),
            Text(detail.description, style: AppTextStyle.mainText),
          ],
          const SizedBox(height: AppSpacing.space5),
          Text('시험 정보', style: AppTextStyle.section),
          if (detail.examInfo.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space0),
            Text(detail.examInfo, style: AppTextStyle.subText),
          ],
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
          if (detail.examSchedules.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space5),
            Text('시험 일정', style: AppTextStyle.section),
            const SizedBox(height: AppSpacing.space2),
            ...detail.examSchedules.map(
              (schedule) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.space2),
                child: ExamScheduleCard(schedule: schedule),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.space3),
        ],
      ),
    );
  }
}
