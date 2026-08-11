import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/button/custom_elevated_button.dart';
import 'package:li_on/core/widgets/layout/app_bottom_sheet.dart';
import 'package:li_on/pages/calendar/model/calendar_event.dart';

/// 일정의 알림 시점을 고르는 바텀시트. 확인을 누르면 고른 값을 돌려주고,
/// 닫으면 null.
class ReminderSelectSheet extends StatefulWidget {
  final CalendarReminder initial;

  const ReminderSelectSheet({super.key, required this.initial});

  @override
  State<ReminderSelectSheet> createState() => _ReminderSelectSheetState();
}

class _ReminderSelectSheetState extends State<ReminderSelectSheet> {
  late CalendarReminder _selected = widget.initial;

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: '알림 설정',
      children: [
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final reminder in CalendarReminder.values)
                  _ReminderOption(
                    label: reminder.label,
                    selected: _selected == reminder,
                    onTap: () => setState(() => _selected = reminder),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: AppSpacing.space4),
          child: CustomElevatedButton(
            text: '확인',
            backgroundColor: AppColors.primary,
            onPressed: () => Navigator.of(context).pop(_selected),
          ),
        ),
      ],
    );
  }
}

class _ReminderOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ReminderOption({
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
        height: 49,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.background, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyle.mainText.copyWith(
                fontSize: 15,
                color: AppColors.text,
              ),
            ),
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: selected
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
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
