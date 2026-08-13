import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/layout/base_scaffold.dart';
import 'package:li_on/core/widgets/snackbar/custom_snackbar.dart';
import 'package:li_on/pages/calendar/provider/calendar_view_model.dart';
import 'package:li_on/pages/calendar/view/schedule_form_sheet.dart';
import 'package:li_on/pages/calendar/widget/calendar_event_tile.dart';
import 'package:li_on/pages/calendar/widget/calendar_grid.dart';
import 'package:li_on/pages/calendar/widget/calendar_month_header.dart';

/// 캘린더 탭 첫 화면. 월간·주간으로 일정을 훑어보고, 오른쪽 아래 버튼으로
/// 새 일정을 추가한다.
class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late DateTime _focusedMonth = _firstOfMonth(DateTime.now());
  late DateTime _selectedDate = _defaultSelectedDate();
  CalendarViewMode _viewMode = CalendarViewMode.monthly;

  static DateTime _firstOfMonth(DateTime date) =>
      DateTime(date.year, date.month, 1);

  // 더미 일정이 이번 달 15일에 몰려 있어, 처음 열었을 때부터 바로 보이게 한다.
  static DateTime _defaultSelectedDate() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, 15);
  }

  // 이동한 달에 선택 날짜의 '일'이 없으면(예: 31일 → 2월) 그 달의 마지막 날로 당긴다.
  static DateTime _clampToMonth(DateTime date, DateTime month) {
    final int lastDay = DateTime(month.year, month.month + 1, 0).day;
    return DateTime(month.year, month.month, date.day.clamp(1, lastDay));
  }

  void _goToPreviousMonth() {
    final DateTime month = DateTime(
      _focusedMonth.year,
      _focusedMonth.month - 1,
      1,
    );
    setState(() {
      _focusedMonth = month;
      _selectedDate = _clampToMonth(_selectedDate, month);
    });
  }

  void _goToNextMonth() {
    final DateTime month = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      1,
    );
    setState(() {
      _focusedMonth = month;
      _selectedDate = _clampToMonth(_selectedDate, month);
    });
  }

  // 주간 화면에서 다른 달의 날짜를 고르면, 월간 화면으로 돌아왔을 때도
  // 그 달이 보이도록 함께 옮긴다.
  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _focusedMonth = _firstOfMonth(date);
    });
  }

  Future<void> _openAddSheet() async {
    final bool? added = await showModalBottomSheet<bool>(
      context: context,
      // 셸 브랜치의 중첩 Navigator가 아니라 최상위에 띄워 화면 전체를 덮는다.
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => ScheduleFormSheet(initialDate: _selectedDate),
    );
    if (added != true || !mounted) return;
    CustomSnackbar.show(
      context,
      message: '일정을 추가했어요',
      type: SnackbarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<CalendarEvent>> eventsAsync = ref.watch(
      calendarEventsProvider,
    );
    final List<CalendarEvent> events = eventsAsync.value ?? const [];
    final List<CalendarEvent> selectedDayEvents =
        events.where((event) => event.occursOn(_selectedDate)).toList()
          ..sort((a, b) => a.startAt.compareTo(b.startAt));

    return BaseScaffold(
      appBar: null,
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddSheet,
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.space3),
          CalendarMonthHeader(
            focusedMonth: _focusedMonth,
            viewMode: _viewMode,
            onPrevious: _goToPreviousMonth,
            onNext: _goToNextMonth,
            onViewModeChanged: (mode) => setState(() => _viewMode = mode),
          ),
          const SizedBox(height: AppSpacing.space1),
          CalendarGrid(
            focusedMonth: _focusedMonth,
            selectedDate: _selectedDate,
            events: events,
            viewMode: _viewMode,
            onSelect: _selectDate,
          ),
          const SizedBox(height: AppSpacing.space2),
          Expanded(
            child: eventsAsync.when(
              data: (_) => selectedDayEvents.isEmpty
                  ? Center(
                      child: Text('일정이 없어요', style: AppTextStyle.subText),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.space5,
                      ),
                      itemCount: selectedDayEvents.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.space1),
                      itemBuilder: (context, index) =>
                          CalendarEventTile(event: selectedDayEvents[index]),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text('일정을 불러오지 못했어요', style: AppTextStyle.subText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
