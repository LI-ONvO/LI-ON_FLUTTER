import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/pages/roadmap/calendar_add/model/calendar_schedule.dart';
import 'package:li_on/pages/roadmap/calendar_add/widget/selection_checkbox.dart';

/// 캘린더에 추가할 일정 한 줄. 체크박스 + 일정 카드로 구성된다.
class ScheduleTile extends StatelessWidget {
  final CalendarSchedule schedule;
  final bool selected;
  final VoidCallback onTap;

  const ScheduleTile({
    super.key,
    required this.schedule,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          SelectionCheckbox(selected: selected, onTap: onTap),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space3,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: AppColors.light,
                borderRadius: BorderRadius.circular(AppSpacing.space2),
              ),
              // 제목이 길어져 여러 줄이 되어도 왼쪽 색 막대가 카드 높이에
              // 맞춰 늘어나도록 한다.
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            schedule.title,
                            style: AppTextStyle.card.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space0),
                          Text(
                            schedule.periodLabel,
                            style: AppTextStyle.subText.copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
