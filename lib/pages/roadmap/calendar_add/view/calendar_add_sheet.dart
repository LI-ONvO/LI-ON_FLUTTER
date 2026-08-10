import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/button/custom_elevated_button.dart';
import 'package:li_on/core/widgets/snackbar/custom_snackbar.dart';
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
  /// null이면 아직 사용자가 선택을 건드리지 않은 상태다. 이때는 챗봇이
  /// 추천한 기본 선택을 그대로 쓴다.
  Set<String>? _selectedIds;
  bool _isSubmitting = false;

  Set<String> _defaultSelection(List<CalendarSchedule> schedules) {
    return schedules
        .where((schedule) => schedule.defaultSelected)
        .map((schedule) => schedule.id)
        .toSet();
  }

  void _toggle(Set<String> current, String id) {
    final Set<String> next = {...current};
    if (!next.remove(id)) next.add(id);
    setState(() => _selectedIds = next);
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
    try {
      await ref
          .read(calendarRepositoryProvider)
          .addSchedules(selectedSchedules);
      if (!mounted) return;
      Navigator.of(context).pop(selectedSchedules.length);
    } catch (_) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        message: '일정을 추가하지 못했어요',
        type: SnackbarType.error,
      );
    } finally {
      // 저장에 실패해도 버튼이 계속 비활성으로 남지 않도록 되돌린다.
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<CalendarSchedule>> schedulesAsync = ref.watch(
      suggestedSchedulesProvider(widget.certificateName),
    );
    final List<CalendarSchedule> schedules = schedulesAsync.value ?? const [];
    // 사용자가 아직 선택을 건드리지 않았으면 챗봇이 추천한 기본 선택을 쓴다.
    // build에서 상태를 쓰지 않도록, 값을 계산만 하고 저장하지 않는다.
    final Set<String> selectedIds =
        _selectedIds ?? _defaultSelection(schedules);
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
                const SizedBox(height: 6),
                // 체크박스(20x20)만이 아니라 라벨을 포함한 줄 전체를 눌러도
                // 토글되도록 감싼다.
                GestureDetector(
                  onTap: schedules.isEmpty
                      ? null
                      : () => _toggleAll(schedules, isAllSelected),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
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
                  ),
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
                              top: AppSpacing.space0,
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
                                onTap: () => _toggle(selectedIds, schedule.id),
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
