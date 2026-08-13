import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/pages/calendar/widget/calendar_grid.dart';

/// 달 이동(‹ 2025년 7월 ›)과 월간/주간 탭을 함께 보여주는 캘린더 머리글.
class CalendarMonthHeader extends StatelessWidget {
  final DateTime focusedMonth;
  final CalendarViewMode viewMode;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<CalendarViewMode> onViewModeChanged;

  const CalendarMonthHeader({
    super.key,
    required this.focusedMonth,
    required this.viewMode,
    required this.onPrevious,
    required this.onNext,
    required this.onViewModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _NavIconButton(icon: Icons.chevron_left, onTap: onPrevious),
            const SizedBox(width: AppSpacing.space3),
            Text(
              '${focusedMonth.year}년 ${focusedMonth.month}월',
              style: AppTextStyle.semiBold.copyWith(fontSize: 18),
            ),
            const SizedBox(width: AppSpacing.space3),
            _NavIconButton(icon: Icons.chevron_right, onTap: onNext),
          ],
        ),
        const SizedBox(height: AppSpacing.space3),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ViewModeTab(
              label: '월간',
              selected: viewMode == CalendarViewMode.monthly,
              onTap: () => onViewModeChanged(CalendarViewMode.monthly),
            ),
            const SizedBox(width: AppSpacing.space6),
            _ViewModeTab(
              label: '주간',
              selected: viewMode == CalendarViewMode.weekly,
              onTap: () => onViewModeChanged(CalendarViewMode.weekly),
            ),
          ],
        ),
        const Divider(height: 1, color: AppColors.background),
      ],
    );
  }
}

class _NavIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Icon(icon, size: 20, color: AppColors.text),
    );
  }
}

class _ViewModeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ViewModeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space1),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyle.mainText.copyWith(
            color: selected ? AppColors.primary : AppColors.placeholder,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
