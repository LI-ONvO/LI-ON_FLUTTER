import 'package:flutter/material.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/pages/certificate_search/model/certificate_detail.dart';
import 'package:li_on/pages/certificate_search/widget/exam_schedule_card.dart';
import 'package:li_on/pages/certificate_search/widget/header_card.dart';
import 'package:li_on/pages/certificate_search/widget/info_row.dart';

class CertificateDetailBody extends StatelessWidget {
  final CertificateDetail detail;

  const CertificateDetailBody({super.key, required this.detail});

  /// 합격률(%)을 "42.5%"로. 값이 없으면 "정보 없음".
  static String _rateLabel(double? rate) =>
      rate == null ? '정보 없음' : '${rate.toStringAsFixed(1)}%';

  /// 응시료(원)를 "19,400원"으로. 값이 없으면 "정보 없음".
  static String _feeLabel(int? fee) {
    if (fee == null) return '정보 없음';
    final String digits = fee.toString();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return '$buffer원';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.space3),
          CertificateHeaderCard(detail: detail),
          if (detail.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space5),
            Text('자격증 소개', style: AppTextStyle.section),
            const SizedBox(height: AppSpacing.space1),
            Text(detail.description, style: AppTextStyle.mainText),
          ],
          const SizedBox(height: AppSpacing.space5),
          Text('시험 정보', style: AppTextStyle.section),
          const SizedBox(height: AppSpacing.space1),
          CertificateInfoRow(
            label: '필기 합격률',
            value: _rateLabel(detail.docPassRate),
          ),
          CertificateInfoRow(
            label: '실기 합격률',
            value: _rateLabel(detail.pracPassRate),
          ),
          CertificateInfoRow(label: '필기 응시료', value: _feeLabel(detail.docFee)),
          CertificateInfoRow(label: '실기 응시료', value: _feeLabel(detail.pracFee)),
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
