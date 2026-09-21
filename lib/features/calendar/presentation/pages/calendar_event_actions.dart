import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/widgets/dialog/confirm_dialog.dart';
import 'package:li_on/core/widgets/snackbar/custom_snackbar.dart';
import 'package:li_on/features/calendar/presentation/view_models/calendar_view_model.dart';
import 'package:li_on/features/calendar/presentation/pages/schedule_form_sheet.dart';

/// 캘린더 화면과 일정 목록이 같은 방식으로 일정을 수정·삭제하도록
/// 동작을 한곳에 모아둔다. `lib/features/data_room/presentation/pages/material_actions.dart`와
/// 같은 패턴이다.

/// 일정 수정 시트를 띄운다. 수정에 성공하면 '일정을 수정했어요' 스낵바를 띄운다.
Future<void> openScheduleEditSheet(
  BuildContext context,
  CalendarEvent event,
) async {
  final bool? edited = await showModalBottomSheet<bool>(
    context: context,
    // 셸 브랜치의 중첩 Navigator가 아니라 최상위에 띄워 화면 전체를 덮는다.
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (context) =>
        ScheduleFormSheet(initialDate: event.startDate, event: event),
  );
  if (edited != true || !context.mounted) return;
  CustomSnackbar.show(
    context,
    message: '일정을 수정했어요',
    type: SnackbarType.success,
  );
}

/// 삭제를 한 번 더 확인받고, 확인하면 일정을 지운다.
Future<void> confirmDeleteEvent(
  BuildContext context,
  WidgetRef ref,
  CalendarEvent event,
) async {
  final bool confirmed = await ConfirmDialog.show(
    context,
    icon: Icons.error_outline,
    title: '일정을 삭제할까요?',
    description: '삭제된 일정은 복구할 수 없어요.',
    confirmText: '삭제',
  );
  if (!confirmed || !context.mounted) return;

  try {
    await ref.read(calendarEventsProvider.notifier).remove(event.id);
    if (context.mounted) {
      CustomSnackbar.show(
        context,
        message: '일정을 삭제했어요',
        type: SnackbarType.success,
      );
    }
  } catch (_) {
    if (context.mounted) {
      CustomSnackbar.show(
        context,
        message: '일정을 삭제하지 못했어요',
        type: SnackbarType.error,
      );
    }
  }
}
