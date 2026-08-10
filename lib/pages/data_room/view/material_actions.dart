import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/widgets/dialog/confirm_dialog.dart';
import 'package:li_on/core/widgets/snackbar/custom_snackbar.dart';
import 'package:li_on/pages/data_room/provider/data_room_view_model.dart';
import 'package:li_on/pages/data_room/view/material_edit_sheet.dart';

/// 자료방 목록과 자료 상세 화면이 같은 방식으로 자료를 수정·삭제하도록
/// ⋮ 메뉴의 동작을 한곳에 모아둔다.

/// 자료 수정 시트를 띄운다.
Future<void> openMaterialEditSheet(
  BuildContext context,
  SavedMaterial material,
) {
  return showModalBottomSheet<bool>(
    context: context,
    // 셸 브랜치의 중첩 Navigator가 아니라 최상위에 띄워 화면 전체를 덮는다.
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (context) => MaterialEditSheet(material: material),
  );
}

/// 삭제를 한 번 더 확인받고, 확인하면 자료를 지운다.
/// 실제로 지웠으면 true.
Future<bool> confirmDeleteMaterial(
  BuildContext context,
  WidgetRef ref,
  SavedMaterial material,
) async {
  final bool confirmed = await ConfirmDialog.show(
    context,
    icon: Icons.error_outline,
    title: '자료를 삭제할까요?',
    description: '삭제된 자료는 복구할 수 없어요.',
    confirmText: '삭제',
  );
  if (!confirmed) return false;

  try {
    await ref.read(dataRoomMaterialsProvider.notifier).remove(material.id);
    return true;
  } catch (_) {
    if (context.mounted) {
      CustomSnackbar.show(
        context,
        message: '자료를 삭제하지 못했어요',
        type: SnackbarType.error,
      );
    }
    return false;
  }
}
