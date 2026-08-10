import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/button/custom_elevated_button.dart';
import 'package:li_on/pages/roadmap/calendar_add/model/calendar_schedule.dart';
import 'package:li_on/pages/roadmap/calendar_add/provider/calendar_repository.dart';
import 'package:li_on/pages/roadmap/calendar_add/widget/schedule_tile.dart';
import 'package:li_on/pages/roadmap/calendar_add/widget/selection_checkbox.dart';

/// 태블릿·웹처럼 폭이 넓은 화면에서 시트가 과하게 늘어나지 않도록 제한한다.
const double _maxSheetWidth = 640;

/// 로드맵 대화에서 나온 학습 일정 중 캘린더에 저장할 항목을 고르는 바텀시트.
/// 닫힐 때 추가한 일정 개수를 돌려준다. 취소하면 null.
class CalendarAddSheet extends ConsumerStatefulWidget {
  final String certificateName;

  const CalendarAddSheet({super.key, required this.certificateName});

  @override
  ConsumerState<CalendarAddSheet> createState() => _CalendarAddSheetState();
}

class _CalendarAddSheetState extends ConsumerState<CalendarAddSheet> {
  /// null이면 아직 일정 목록을 받지 못해 초기 선택이 정해지지 않은 상태.
  Set<String>? _selectedIds;
  bool _isSubmitting = false;

  void _toggle(String id) {
    setState(() {
      final Set<String> selected = {...?_selectedIds};
      if (!selected.remove(id)) selected.add(id);
      _selectedIds = selected;
    });
  }

  void _toggleAll(List<CalendarSchedule> schedules, bool isAllSelected) {
    setState(() {
      _selectedIds = isAllSelected
          ? <String>{}
          : schedules.map((schedule) => schedule.id).toSet();
    });
  }

  Future<void> _submit(List<CalendarSchedule> selectedSchedules) async {
    setState(() => _isSubmitting = true);
    await ref.read(calendarRepositoryProvider).addSchedules(selectedSchedules);
    if (!mounted) return;
    Navigator.of(context).pop(selectedSchedules.length);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<CalendarSchedule>> schedulesAsync = ref.watch(
      suggestedSchedulesProvider(widget.certificateName),
    );
    final List<CalendarSchedule> schedules = schedulesAsync.value ?? const [];
    // 목록이 처음 도착한 시점에 챗봇이 추천한 항목을 기본 선택으로 채운다.
    // 이후에는 사용자의 선택을 그대로 유지한다.
    if (schedulesAsync.hasValue && _selectedIds == null) {
      _selectedIds = schedules
          .where((schedule) => schedule.defaultSelected)
          .map((schedule) => schedule.id)
          .toSet();
    }
    final Set<String> selectedIds = _selectedIds ?? const <String>{};
    final bool isAllSelected =
        schedules.isNotEmpty && selectedIds.length == schedules.length;
    final List<CalendarSchedule> selectedSchedules = schedules
        .where((schedule) => selectedIds.contains(schedule.id))
        .toList();

    return SafeArea(
      top: false,
      // heightFactor 1로 내용 높이만큼만 차지해야 시트가 화면 가운데로 뜨지
      // 않고 하단에 붙는다. 가로는 넓은 화면에서 가운데 정렬된다.
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _maxSheetWidth,
            // 일정이 많아도 시트가 상태바 아래까지 차오르지 않도록 제한한다.
            // 넘치는 목록은 안쪽 Flexible + ListView가 스크롤로 처리한다.
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 14),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Row(
                  children: [
                    Text('캘린더에 추가', style: AppTextStyle.section),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: const Icon(Icons.close, color: AppColors.text),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    SelectionCheckbox(
                      selected: isAllSelected,
                      onTap: schedules.isEmpty
                          ? null
                          : () => _toggleAll(schedules, isAllSelected),
                    ),
                    const SizedBox(width: AppSpacing.space1),
                    Text('전체 선택', style: AppTextStyle.mainText),
                  ],
                ),
                Flexible(
                  child: schedulesAsync.when(
                    data: (schedules) => schedules.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.space5,
                            ),
                            child: Text(
                              '추가할 일정이 없어요',
                              style: AppTextStyle.subText,
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.only(
                              top: AppSpacing.space2,
                            ),
                            shrinkWrap: true,
                            itemCount: schedules.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.space1),
                            itemBuilder: (context, index) {
                              final CalendarSchedule schedule =
                                  schedules[index];
                              return ScheduleTile(
                                schedule: schedule,
                                selected: selectedIds.contains(schedule.id),
                                onTap: () => _toggle(schedule.id),
                              );
                            },
                          ),
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: AppSpacing.space5,
                      ),
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stackTrace) => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.space5,
                      ),
                      child: Text('일정을 불러오지 못했어요', style: AppTextStyle.subText),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.space2,
                    bottom: AppSpacing.space4,
                  ),
                  child: CustomElevatedButton(
                    text: '${selectedSchedules.length}개 일정 추가',
                    backgroundColor: AppColors.primary,
                    onPressed: selectedSchedules.isEmpty || _isSubmitting
                        ? null
                        : () => _submit(selectedSchedules),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
