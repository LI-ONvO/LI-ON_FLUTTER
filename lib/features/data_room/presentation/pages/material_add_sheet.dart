import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/button/custom_elevated_button.dart';
import 'package:li_on/core/widgets/layout/app_bottom_sheet.dart';
import 'package:li_on/core/widgets/snackbar/custom_snackbar.dart';
import 'package:li_on/core/widgets/text_field/custom_text_field.dart';
import 'package:li_on/features/data_room/presentation/view_models/data_room_view_model.dart';

/// 자료방에서 제목·링크·메모를 직접 입력해 자료를 추가하는 바텀시트.
/// 추가를 마치면 true를 돌려주고, 취소하면 null.
class MaterialAddSheet extends ConsumerStatefulWidget {
  const MaterialAddSheet({super.key});

  @override
  ConsumerState<MaterialAddSheet> createState() => _MaterialAddSheetState();
}

class _MaterialAddSheetState extends ConsumerState<MaterialAddSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSaving = true);
    try {
      await ref
          .read(dataRoomMaterialsProvider.notifier)
          .add(
            title: _titleController.text.trim(),
            category: etcCategory,
            source: '',
            type: MaterialResourceType.link,
            url: _urlController.text.trim(),
            memo: _memoController.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        message: '자료를 추가하지 못했어요',
        type: SnackbarType.error,
      );
    } finally {
      // 추가에 실패해도 버튼이 계속 비활성으로 남지 않도록 되돌린다.
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: '자료 추가',
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
                const SheetLabel('링크'),
                CustomTextField(
                  hintText: 'https://',
                  controller: _urlController,
                  keyboardType: TextInputType.url,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                ),
                const SizedBox(height: AppSpacing.space3),
                const SheetLabel('메모'),
                CustomTextField(
                  hintText: '메모를 남겨보세요',
                  controller: _memoController,
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
          // 제목과 링크가 모두 있어야 추가할 수 있으므로 두 입력창을
          // 함께 지켜보며 버튼의 활성 상태를 갱신한다.
          child: ListenableBuilder(
            listenable: Listenable.merge([_titleController, _urlController]),
            builder: (context, child) => CustomElevatedButton(
              text: '추가 완료',
              backgroundColor: AppColors.primary,
              onPressed:
                  _isSaving ||
                      _titleController.text.trim().isEmpty ||
                      _urlController.text.trim().isEmpty
                  ? null
                  : _submit,
            ),
          ),
        ),
      ],
    );
  }
}
