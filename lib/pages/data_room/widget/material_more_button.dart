import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';

/// ⋮ 메뉴에서 고를 수 있는 동작.
enum MaterialMenuAction { edit, delete }

/// 디자인상 메뉴의 고정 폭.
const double _menuWidth = 140;

/// 자료의 ⋮ 버튼. 누르면 버튼 바로 아래에 수정·삭제 메뉴가 열린다.
/// 자료방 목록과 자료 상세 화면이 함께 쓴다.
class MaterialMoreButton extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// 앱바(20)와 목록(18)에서 아이콘 크기가 다르다.
  final double iconSize;

  const MaterialMoreButton({
    super.key,
    required this.onEdit,
    required this.onDelete,
    this.iconSize = 20,
  });

  Widget _item(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Text(label, style: AppTextStyle.mainText.copyWith(color: color)),
      ],
    );
  }

  Future<void> _openMenu(BuildContext context) async {
    final RenderBox button = context.findRenderObject()! as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final Offset topLeft = button.localToGlobal(Offset.zero, ancestor: overlay);

    final MaterialMenuAction? action = await showMenu<MaterialMenuAction>(
      context: context,
      color: AppColors.white,
      elevation: 4,
      constraints: const BoxConstraints.tightFor(width: _menuWidth),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      // 버튼 바로 아래에 붙인다. 오른쪽 끝에 가까우면 화면 안으로 밀려 들어와
      // 자연스럽게 오른쪽 정렬된다.
      position: RelativeRect.fromLTRB(
        topLeft.dx,
        topLeft.dy + button.size.height,
        overlay.size.width - topLeft.dx - button.size.width,
        0,
      ),
      items: [
        PopupMenuItem<MaterialMenuAction>(
          value: MaterialMenuAction.edit,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _item(Icons.edit_outlined, '수정', AppColors.text),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<MaterialMenuAction>(
          value: MaterialMenuAction.delete,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _item(Icons.delete_outline, '삭제', AppColors.danger),
        ),
      ],
    );

    if (action == null || !context.mounted) return;
    switch (action) {
      case MaterialMenuAction.edit:
        onEdit();
      case MaterialMenuAction.delete:
        onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openMenu(context),
      behavior: HitTestBehavior.opaque,
      // 아이콘만으로는 누르기 어려워 좌우로 탭 영역을 조금 넓힌다.
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Icon(Icons.more_vert, size: iconSize, color: AppColors.text),
      ),
    );
  }
}
