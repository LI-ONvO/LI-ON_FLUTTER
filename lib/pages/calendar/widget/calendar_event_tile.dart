import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/pages/calendar/model/calendar_event.dart';

/// 선택한 날짜의 일정 한 줄. 왼쪽 색 막대로 [CalendarEvent.category]를
/// 구분한다.
class CalendarEventTile extends StatelessWidget {
  final CalendarEvent event;

  const CalendarEventTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.space1),
      child: Container(
        height: 56,
        color: AppColors.surface,
        child: Row(
          children: [
            Container(width: 4, color: event.category.accentColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space2,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.title,
                      style: AppTextStyle.card,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(event.timeLabel, style: AppTextStyle.subText),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
