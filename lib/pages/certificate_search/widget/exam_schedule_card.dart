import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/pages/certificate_search/model/certificate_detail.dart';

/// "2026.08.16" 형식의 날짜 표기. intl 의존성이 없어 직접 포맷한다.
String _dateLabel(DateTime date) {
  final String month = date.month.toString().padLeft(2, '0');
  final String day = date.day.toString().padLeft(2, '0');
  return '${date.year}.$month.$day';
}

String _rangeLabel(DateTime start, DateTime end) =>
    '${_dateLabel(start)} ~ ${_dateLabel(end)}';

class ExamScheduleCard extends StatelessWidget {
  final ExamSchedule schedule;

  const ExamScheduleCard({super.key, required this.schedule});

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
          Text(
            '${schedule.implYy}년 ${schedule.implSeq}회',
            style: AppTextStyle.baseTextStyle.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.space1),
          _ScheduleRow(
            label: '필기 접수',
            value: _rangeLabel(schedule.docRegStartDt, schedule.docRegEndDt),
          ),
          _ScheduleRow(
            label: '필기 시험',
            value: _rangeLabel(schedule.docExamStartDt, schedule.docExamEndDt),
          ),
          _ScheduleRow(label: '필기 합격 발표', value: _dateLabel(schedule.docPassDt)),
          const SizedBox(height: AppSpacing.space1),
          _ScheduleRow(
            label: '실기 접수',
            value: _rangeLabel(schedule.pracRegStartDt, schedule.pracRegEndDt),
          ),
          _ScheduleRow(
            label: '실기 시험',
            value: _rangeLabel(
              schedule.pracExamStartDt,
              schedule.pracExamEndDt,
            ),
          ),
          _ScheduleRow(
            label: '실기 합격 발표',
            value: _dateLabel(schedule.pracPassDt),
          ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final String label;
  final String value;

  const _ScheduleRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyle.subText.copyWith(fontSize: 13),
          ),
          Text(
            value,
            style: AppTextStyle.baseTextStyle.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
