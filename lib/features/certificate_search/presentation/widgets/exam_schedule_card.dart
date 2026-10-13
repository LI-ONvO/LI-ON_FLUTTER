import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/features/certificate_search/data/certificate_detail.dart';

/// "2026.08.16" 형식의 날짜 표기. intl 의존성이 없어 직접 포맷한다.
/// 날짜가 없으면 `null`.
String? _dateLabel(DateTime? date) {
  if (date == null) return null;
  final String month = date.month.toString().padLeft(2, '0');
  final String day = date.day.toString().padLeft(2, '0');
  return '${date.year}.$month.$day';
}

/// "시작 ~ 종료" 표기. 한쪽만 있으면 있는 날짜만, 둘 다 없으면 `null`.
String? _rangeLabel(DateTime? start, DateTime? end) {
  final String? from = _dateLabel(start);
  final String? to = _dateLabel(end);
  return (from != null && to != null) ? '$from ~ $to' : from ?? to;
}

class ExamScheduleCard extends StatelessWidget {
  final ExamSchedule schedule;

  const ExamScheduleCard({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    // 필기·실기 묶음. 값이 없는 행은 그리지 않고, 행이 하나도 없는 묶음은 통째로 뺀다.
    final List<List<(String, String?)>> sections = [
      [
        ('필기 접수', _rangeLabel(schedule.docRegStartDt, schedule.docRegEndDt)),
        ('필기 시험', _rangeLabel(schedule.docExamStartDt, schedule.docExamEndDt)),
        ('필기 합격 발표', _dateLabel(schedule.docPassDt)),
      ],
      [
        ('실기 접수', _rangeLabel(schedule.pracRegStartDt, schedule.pracRegEndDt)),
        (
          '실기 시험',
          _rangeLabel(schedule.pracExamStartDt, schedule.pracExamEndDt),
        ),
        ('실기 합격 발표', _dateLabel(schedule.pracPassDt)),
      ],
    ];

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
          for (final rows in sections)
            if (rows.any((row) => row.$2 != null)) ...[
              const SizedBox(height: AppSpacing.space1),
              for (final (label, value) in rows)
                if (value != null) _ScheduleRow(label: label, value: value),
            ],
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
          Text(label, style: AppTextStyle.subText.copyWith(fontSize: 13)),
          Text(value, style: AppTextStyle.baseTextStyle.copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}
