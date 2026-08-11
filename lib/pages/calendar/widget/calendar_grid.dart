import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/pages/calendar/model/calendar_event.dart';

/// 캘린더가 한 달 전체를 보여줄지, 선택한 날짜가 속한 한 주만 보여줄지.
enum CalendarViewMode { monthly, weekly }

const List<String> _weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];

/// 요일 머리글과 날짜 칸을 그리는 캘린더 그리드.
/// [viewMode]가 [CalendarViewMode.monthly]면 [focusedMonth] 전체를,
/// [CalendarViewMode.weekly]면 [selectedDate]가 속한 한 주만 그린다.
class CalendarGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDate;
  final List<CalendarEvent> events;
  final CalendarViewMode viewMode;
  final ValueChanged<DateTime> onSelect;

  const CalendarGrid({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    required this.events,
    required this.viewMode,
    required this.onSelect,
  });

  static List<DateTime?> _monthCells(DateTime month) {
    final DateTime first = DateTime(month.year, month.month, 1);
    // DateTime.weekday는 월요일이 1, 일요일이 7이라 7로 나눈 나머지를 쓰면
    // 일요일이 0이 되어 요일 머리글 순서와 맞아떨어진다.
    final int leading = first.weekday % 7;
    final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    return [
      for (int i = 0; i < leading; i++) null,
      for (int day = 1; day <= daysInMonth; day++)
        DateTime(month.year, month.month, day),
    ];
  }

  static List<DateTime> _weekCells(DateTime selected) {
    final DateTime day = DateTime(selected.year, selected.month, selected.day);
    final int offset = day.weekday % 7;
    final DateTime sunday = day.subtract(Duration(days: offset));
    return [for (int i = 0; i < 7; i++) sunday.add(Duration(days: i))];
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final List<DateTime?> cells = viewMode == CalendarViewMode.monthly
        ? _monthCells(focusedMonth)
        : _weekCells(selectedDate);

    final List<List<DateTime?>> weeks = [
      for (int i = 0; i < cells.length; i += 7)
        cells.sublist(i, i + 7 > cells.length ? cells.length : i + 7),
    ];

    return Column(
      children: [
        Row(
          children: [
            for (final label in _weekdayLabels)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.subText,
                  ),
                ),
              ),
          ],
        ),
        for (final week in weeks)
          Row(
            children: [
              for (final day in week)
                Expanded(
                  child: day == null
                      ? const SizedBox(height: 48)
                      : _DayCell(
                          day: day,
                          selected: _isSameDay(day, selectedDate),
                          hasEvent: events.any((event) => event.occursOn(day)),
                          onTap: () => onSelect(day),
                        ),
                ),
            ],
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime day;
  final bool selected;
  final bool hasEvent;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.selected,
    required this.hasEvent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 48,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${day.day}',
                style: AppTextStyle.mainText.copyWith(
                  fontSize: 14,
                  color: selected ? AppColors.white : AppColors.text,
                ),
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              width: 4,
              height: 4,
              child: hasEvent
                  ? const DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
