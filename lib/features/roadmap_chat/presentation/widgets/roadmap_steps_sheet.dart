import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/layout/app_bottom_sheet.dart';
import 'package:li_on/core/widgets/progress/custom_progress_indicator.dart';
import 'package:li_on/core/widgets/snackbar/custom_snackbar.dart';
import 'package:li_on/features/calendar/presentation/view_models/calendar_view_model.dart';
import 'package:li_on/features/roadmap/data/roadmap_detail.dart';
import 'package:li_on/features/roadmap_chat/presentation/view_models/roadmap_steps_provider.dart';

/// 목표일만 있는 스텝을 캘린더에 넣을 때 쓰는 시작 시각과 길이.
const int _eventStartHour = 9;
const Duration _eventDuration = Duration(hours: 1);

/// 로드맵 대화의 "로드맵 생성" 버튼으로 여는 시트.
/// 이 세션의 로드맵이 아직 없으면 AI로 만든 뒤 스텝 목록을 보여주고,
/// 스텝마다 목표일로 캘린더에 저장할 수 있다.
class RoadmapStepsSheet extends ConsumerStatefulWidget {
  const RoadmapStepsSheet({super.key, required this.sessionId});

  final int sessionId;

  @override
  ConsumerState<RoadmapStepsSheet> createState() => _RoadmapStepsSheetState();
}

class _RoadmapStepsSheetState extends ConsumerState<RoadmapStepsSheet> {
  /// 이 시트에서 방금 저장한 스텝. 캘린더 목록이 갱신되기 전에도 중복 저장을
  /// 막는다.
  final Set<int> _savedIds = {};
  int? _savingId;

  Future<void> _save(RoadmapStep step) async {
    final DateTime? targetDate = step.targetDate;
    if (targetDate == null) return;
    setState(() => _savingId = step.id);
    try {
      final DateTime startAt = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        _eventStartHour,
      );
      await ref
          .read(calendarEventsProvider.notifier)
          .add(
            title: step.title,
            startAt: startAt,
            endAt: startAt.add(_eventDuration),
            reminder: CalendarReminder.none,
            roadmapStepId: step.id,
            description: step.description,
          );
      if (!mounted) return;
      setState(() {
        _savedIds.add(step.id);
        _savingId = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _savingId = null);
      CustomSnackbar.show(
        context,
        message: '캘린더에 저장하지 못했어요',
        type: SnackbarType.error,
      );
    }
  }

  void _retry() => ref.invalidate(roadmapStepsProvider(widget.sessionId));

  @override
  Widget build(BuildContext context) {
    final Set<int> calendarStepIds = {
      for (final CalendarEvent event
          in ref.watch(calendarEventsProvider).value ?? const [])
        ?event.roadmapStepId,
    };

    return AppBottomSheet(
      title: '학습 로드맵',
      children: [
        Flexible(
          child: ref
              .watch(roadmapStepsProvider(widget.sessionId))
              .when(
                skipLoadingOnRefresh: false,
                loading: () => const _SheetMessage(
                  message: '로드맵을 만들고 있어요. 잠시만 기다려주세요',
                  loading: true,
                ),
                error: (_, _) =>
                    _SheetMessage(message: '로드맵을 만들지 못했어요', onRetry: _retry),
                data: (steps) {
                  if (steps.isEmpty) {
                    return _SheetMessage(
                      message: '표시할 로드맵이 없어요',
                      onRetry: _retry,
                    );
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.space3,
                    ),
                    child: Column(
                      spacing: AppSpacing.space2,
                      children: [
                        for (final RoadmapStep step in steps)
                          _StepTile(
                            step: step,
                            saved:
                                _savedIds.contains(step.id) ||
                                calendarStepIds.contains(step.id),
                            saving: _savingId == step.id,
                            onSave: () => _save(step),
                          ),
                      ],
                    ),
                  );
                },
              ),
        ),
        const SizedBox(height: AppSpacing.space3),
      ],
    );
  }
}

/// 로딩·실패·빈 상태를 시트 가운데에 한 줄로 보여준다. [onRetry]가 있으면
/// 다시 시도 버튼을 함께 둔다.
class _SheetMessage extends StatelessWidget {
  const _SheetMessage({
    required this.message,
    this.loading = false,
    this.onRetry,
  });

  final String message;
  final bool loading;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.space2,
          children: [
            if (loading) const CustomProgressIndicator(),
            Text(message, style: AppTextStyle.subText),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                child: Text(
                  '다시 시도',
                  style: AppTextStyle.mainText.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.step,
    required this.saved,
    required this.saving,
    required this.onSave,
  });

  final RoadmapStep step;
  final bool saved;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final DateTime? targetDate = step.targetDate;
    final String dateLabel = targetDate == null
        ? '목표일 미정'
        : '${targetDate.year}.${targetDate.month.toString().padLeft(2, '0')}.'
              '${targetDate.day.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space3),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.background),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(step.title, style: AppTextStyle.card),
          const SizedBox(height: AppSpacing.space1),
          Text(step.description, style: AppTextStyle.subText),
          const SizedBox(height: AppSpacing.space2),
          Row(
            children: [
              Text(dateLabel, style: AppTextStyle.subText),
              const Spacer(),
              TextButton(
                onPressed: targetDate == null || saved || saving
                    ? null
                    : onSave,
                child: Text(
                  saved ? '추가됨' : (saving ? '추가 중…' : '캘린더에 추가'),
                  style: AppTextStyle.mainText.copyWith(
                    color: saved || targetDate == null
                        ? AppColors.placeholder
                        : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
