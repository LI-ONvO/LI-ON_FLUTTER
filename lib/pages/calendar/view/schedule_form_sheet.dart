import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/button/custom_elevated_button.dart';
import 'package:li_on/core/widgets/layout/app_bottom_sheet.dart';
import 'package:li_on/core/widgets/snackbar/custom_snackbar.dart';
import 'package:li_on/core/widgets/text_field/custom_text_field.dart';
import 'package:li_on/pages/calendar/provider/calendar_view_model.dart';
import 'package:li_on/pages/calendar/view/reminder_select_sheet.dart';

/// 새 일정을 추가하는 바텀시트. 저장하면 true를 돌려주고, 취소하면 null.
class ScheduleFormSheet extends ConsumerStatefulWidget {
  final DateTime initialDate;

  const ScheduleFormSheet({super.key, required this.initialDate});

  @override
  ConsumerState<ScheduleFormSheet> createState() => _ScheduleFormSheetState();
}

class _ScheduleFormSheetState extends ConsumerState<ScheduleFormSheet> {
  late final TextEditingController _titleController = TextEditingController();
  late final TextEditingController _memoController = TextEditingController();

  late DateTime _startDate = widget.initialDate;
  late DateTime _endDate = widget.initialDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 19, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 21, minute: 0);
  CalendarReminder _reminder = CalendarReminder.minutes30;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final DateTime initial = isStart ? _startDate : _endDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(initial.year - 1),
      lastDate: DateTime(initial.year + 2),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) _endDate = _startDate;
      } else {
        _endDate = picked.isBefore(_startDate) ? _startDate : picked;
      }
    });
  }

  Future<void> _pickTime({required bool isStart}) async {
    final TimeOfDay initial = isStart ? _startTime : _endTime;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  Future<void> _pickReminder() async {
    final CalendarReminder? picked = await showModalBottomSheet<
      CalendarReminder
    >(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => ReminderSelectSheet(initial: _reminder),
    );
    if (picked == null) return;
    setState(() => _reminder = picked);
  }

  DateTime _combine(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  Future<void> _submit() async {
    final DateTime startAt = _combine(_startDate, _startTime);
    final DateTime endAt = _combine(_endDate, _endTime);
    if (endAt.isBefore(startAt)) {
      CustomSnackbar.show(
        context,
        message: '종료 시각이 시작 시각보다 빨라요',
        type: SnackbarType.error,
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final String memo = _memoController.text.trim();
      await ref
          .read(calendarEventsProvider.notifier)
          .add(
            title: _titleController.text.trim(),
            startAt: startAt,
            endAt: endAt,
            category: CalendarEventCategory.study,
            reminder: _reminder,
            linkedCertificate: dummyLinkedCertificate,
            memo: memo.isEmpty ? null : memo,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        message: '일정을 추가하지 못했어요',
        type: SnackbarType.error,
      );
    } finally {
      // 저장에 실패해도 버튼이 계속 비활성으로 남지 않도록 되돌린다.
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: '일정 추가',
      children: [
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SheetLabel('일정 제목'),
                CustomTextField(
                  hintText: '일정 제목을 입력하세요',
                  controller: _titleController,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                ),
                const SizedBox(height: AppSpacing.space3),
                const SheetLabel('날짜'),
                Row(
                  children: [
                    Expanded(
                      child: _PickerField(
                        icon: Icons.calendar_today_outlined,
                        label: '${_startDate.month}/${_startDate.day}',
                        onTap: () => _pickDate(isStart: true),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.space1,
                      ),
                      child: Text(
                        '~',
                        style: TextStyle(color: AppColors.placeholder),
                      ),
                    ),
                    Expanded(
                      child: _PickerField(
                        icon: Icons.calendar_today_outlined,
                        label: '${_endDate.month}/${_endDate.day}',
                        onTap: () => _pickDate(isStart: false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space3),
                const SheetLabel('시간'),
                Row(
                  children: [
                    Expanded(
                      child: _PickerField(
                        icon: Icons.access_time,
                        label: formatKoreanTimeOfDay(_startTime),
                        onTap: () => _pickTime(isStart: true),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.space1,
                      ),
                      child: Text(
                        '~',
                        style: TextStyle(color: AppColors.placeholder),
                      ),
                    ),
                    Expanded(
                      child: _PickerField(
                        icon: Icons.access_time,
                        label: formatKoreanTimeOfDay(_endTime),
                        onTap: () => _pickTime(isStart: false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.notifications_outlined,
                          size: 18,
                          color: AppColors.text,
                        ),
                        SizedBox(width: 10),
                        Text(
                          '알림',
                          style: TextStyle(
                            fontFamily: 'HelveticaNeue',
                            fontSize: 15,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _pickReminder,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          Text(_reminder.label, style: AppTextStyle.mainText),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 16,
                            color: AppColors.subText,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '연결된 자격증',
                      style: TextStyle(
                        fontFamily: 'HelveticaNeue',
                        fontSize: 15,
                        color: AppColors.text,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.light,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        dummyLinkedCertificate,
                        style: AppTextStyle.subText.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space3),
                const SheetLabel('메모'),
                CustomTextField(
                  hintText: '메모를 남겨보세요',
                  controller: _memoController,
                  // 메모가 길어지면 5줄까지 늘어나고 그 뒤로는 안에서 스크롤된다.
                  minLines: 3,
                  maxLines: 5,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: AppSpacing.space4),
          // 제목이 비어 있으면 저장할 수 없으므로 입력창을 지켜보며
          // 버튼의 활성 상태를 갱신한다.
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _titleController,
            builder: (context, value, child) => CustomElevatedButton(
              text: '저장',
              backgroundColor: AppColors.primary,
              onPressed: _isSaving || value.text.trim().isEmpty
                  ? null
                  : _submit,
            ),
          ),
        ),
      ],
    );
  }
}

class _PickerField extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickerField({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.subText),
            const SizedBox(width: AppSpacing.space1),
            Text(
              label,
              style: AppTextStyle.mainText.copyWith(color: AppColors.text),
            ),
          ],
        ),
      ),
    );
  }
}
