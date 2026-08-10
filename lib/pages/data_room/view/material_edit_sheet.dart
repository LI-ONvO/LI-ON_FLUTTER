import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/badge/custom_badge.dart';
import 'package:li_on/core/widgets/button/custom_elevated_button.dart';
import 'package:li_on/core/widgets/layout/app_bottom_sheet.dart';
import 'package:li_on/core/widgets/snackbar/custom_snackbar.dart';
import 'package:li_on/core/widgets/text_field/custom_text_field.dart';
import 'package:li_on/pages/data_room/provider/data_room_view_model.dart';

/// 저장한 자료의 제목·카테고리·메모를 고치는 바텀시트.
/// 수정을 마치면 true를 돌려주고, 취소하면 null.
class MaterialEditSheet extends ConsumerStatefulWidget {
  final SavedMaterial material;

  const MaterialEditSheet({super.key, required this.material});

  @override
  ConsumerState<MaterialEditSheet> createState() => _MaterialEditSheetState();
}

class _MaterialEditSheetState extends ConsumerState<MaterialEditSheet> {
  late final TextEditingController _titleController = TextEditingController(
    text: widget.material.title,
  );
  late final TextEditingController _memoController = TextEditingController(
    text: widget.material.memo,
  );
  late String _selectedCategory = widget.material.category;

  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSaving = true);
    try {
      await ref
          .read(dataRoomMaterialsProvider.notifier)
          .edit(
            id: widget.material.id,
            title: _titleController.text.trim(),
            category: _selectedCategory,
            memo: _memoController.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        message: '자료를 수정하지 못했어요',
        type: SnackbarType.error,
      );
    } finally {
      // 수정에 실패해도 버튼이 계속 비활성으로 남지 않도록 되돌린다.
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categories = ref.watch(materialCategoryOptionsProvider);

    return AppBottomSheet(
      title: '자료 수정',
      children: [
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SheetLabel('제목'),
                CustomTextField(
                  hintText: '자료 제목을 입력하세요',
                  controller: _titleController,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                ),
                const SizedBox(height: AppSpacing.space3),
                const SheetLabel('카테고리'),
                Wrap(
                  spacing: AppSpacing.space1,
                  runSpacing: AppSpacing.space1,
                  children: [
                    for (final category in categories)
                      CustomBadge(
                        field: category,
                        compact: true,
                        selected: _selectedCategory == category,
                        onTap: () =>
                            setState(() => _selectedCategory = category),
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
          // 제목이 비어 있으면 수정할 수 없으므로 입력창을 지켜보며
          // 버튼의 활성 상태를 갱신한다.
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _titleController,
            builder: (context, value, child) => CustomElevatedButton(
              text: '수정 완료',
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
