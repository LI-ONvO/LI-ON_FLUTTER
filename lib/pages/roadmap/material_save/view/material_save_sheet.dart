import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/badge/custom_badge.dart';
import 'package:li_on/core/widgets/button/custom_elevated_button.dart';
import 'package:li_on/core/widgets/layout/app_bottom_sheet.dart';
import 'package:li_on/core/widgets/snackbar/custom_snackbar.dart';
import 'package:li_on/core/widgets/text_field/custom_text_field.dart';
import 'package:li_on/pages/data_room/provider/data_room_view_model.dart';
import 'package:li_on/pages/roadmap/material_save/model/material_resource.dart';
import 'package:li_on/pages/roadmap/material_save/provider/material_repository.dart';
import 'package:li_on/pages/roadmap/material_save/widget/resource_preview_card.dart';

/// 로드맵 대화에서 추천받은 자료를 메모·카테고리와 함께 자료방에 저장하는
/// 바텀시트. 닫힐 때 저장한 자료의 제목을 돌려준다. 취소하면 null.
class MaterialSaveSheet extends ConsumerStatefulWidget {
  final String certificateName;

  const MaterialSaveSheet({super.key, required this.certificateName});

  @override
  ConsumerState<MaterialSaveSheet> createState() => _MaterialSaveSheetState();
}

class _MaterialSaveSheetState extends ConsumerState<MaterialSaveSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  /// 추천 자료의 제목으로 입력창을 이미 채웠는지 여부.
  /// 자료를 다시 불러와도 사용자가 고쳐둔 제목을 덮어쓰지 않게 한다.
  bool _titleFilled = false;

  /// null이면 아직 사용자가 카테고리를 고르지 않은 상태다.
  /// 이때는 첫 번째 카테고리(해당 자격증)를 기본 선택으로 쓴다.
  String? _selectedCategory;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // 시트를 열 때 자료가 이미 불러와져 있으면 build의 ref.listen은 변화가
    // 없어 울리지 않는다. 그 경우에도 제목이 비지 않도록 여기서 먼저 채운다.
    _fillTitle(
      ref.read(materialSaveDataProvider(widget.certificateName)).value,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  /// 추천 제목으로 입력창을 한 번만 채운다.
  /// 사용자가 고쳐둔 제목을 나중에 덮어쓰지 않게 한다.
  void _fillTitle(MaterialSaveData? loaded) {
    if (loaded == null || _titleFilled) return;
    _titleFilled = true;
    _titleController.text = loaded.resource.title;
  }

  Future<void> _save(MaterialResource resource, String category) async {
    final String title = _titleController.text.trim();
    setState(() => _isSaving = true);
    try {
      await ref
          .read(dataRoomMaterialsProvider.notifier)
          .add(
            title: title,
            category: category,
            source: '${widget.certificateName} 로드맵 채팅',
            type: resource.type,
            url: resource.url,
            memo: _memoController.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pop(title);
    } catch (_) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        message: '자료를 저장하지 못했어요',
        type: SnackbarType.error,
      );
    } finally {
      // 저장에 실패해도 버튼이 계속 비활성으로 남지 않도록 되돌린다.
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _form(MaterialSaveData data, String? selectedCategory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 입력 중인 제목이 미리보기에도 바로 반영되도록 입력창을 지켜본다.
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _titleController,
          builder: (context, value, child) =>
              ResourcePreviewCard(resource: data.resource, title: value.text),
        ),
        const SizedBox(height: AppSpacing.space3),
        const SheetLabel('자료 제목'),
        CustomTextField(
          hintText: '자료방에 저장할 제목을 입력하세요',
          controller: _titleController,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 11,
          ),
        ),
        const SizedBox(height: AppSpacing.space3),
        const SheetLabel('메모 추가 (선택)'),
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
        const SizedBox(height: AppSpacing.space3),
        const SheetLabel('카테고리'),
        Wrap(
          spacing: AppSpacing.space1,
          runSpacing: AppSpacing.space1,
          children: [
            for (final category in data.categories)
              CustomBadge(
                field: category,
                compact: true,
                selected: selectedCategory == category,
                onTap: () => setState(() => _selectedCategory = category),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = materialSaveDataProvider(widget.certificateName);
    // 로딩이 끝나면 추천 제목으로 입력창을 채워준다. 사용자는 이 제목을
    // 그대로 저장하거나 원하는 제목으로 고칠 수 있다.
    ref.listen(provider, (previous, next) => _fillTitle(next.value));

    final AsyncValue<MaterialSaveData> dataAsync = ref.watch(provider);
    final MaterialSaveData? data = dataAsync.value;
    // 사용자가 아직 고르지 않았으면 첫 카테고리(해당 자격증)를 기본으로 쓴다.
    // build에서 상태를 쓰지 않도록, 값을 계산만 하고 저장하지 않는다.
    final String? selectedCategory =
        _selectedCategory ??
        (data == null || data.categories.isEmpty
            ? null
            : data.categories.first);

    return AppBottomSheet(
      title: '자료방에 저장',
      children: [
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: AppSpacing.space3),
            child: dataAsync.when(
              data: (data) => _form(data, selectedCategory),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.space5),
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.space5,
                ),
                child: Text('자료를 불러오지 못했어요', style: AppTextStyle.subText),
              ),
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
              onPressed:
                  data == null ||
                      selectedCategory == null ||
                      _isSaving ||
                      value.text.trim().isEmpty
                  ? null
                  : () => _save(data.resource, selectedCategory),
            ),
          ),
        ),
      ],
    );
  }
}
