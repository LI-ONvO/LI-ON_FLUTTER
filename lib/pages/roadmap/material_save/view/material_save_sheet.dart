import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/badge/custom_badge.dart';
import 'package:li_on/core/widgets/button/custom_elevated_button.dart';
import 'package:li_on/core/widgets/text_field/custom_text_field.dart';
import 'package:li_on/pages/roadmap/material_save/model/material_resource.dart';
import 'package:li_on/pages/roadmap/material_save/provider/material_repository.dart';
import 'package:li_on/pages/roadmap/material_save/widget/resource_preview_card.dart';

/// 태블릿·웹처럼 폭이 넓은 화면에서 시트가 과하게 늘어나지 않도록 제한한다.
const double _maxSheetWidth = 640;

/// 로드맵 대화에서 추천받은 자료를 메모·카테고리와 함께 자료방에 저장하는
/// 바텀시트. 닫힐 때 저장한 자료의 제목을 돌려준다. 취소하면 null.
class MaterialSaveSheet extends ConsumerStatefulWidget {
  final String certificateName;

  const MaterialSaveSheet({super.key, required this.certificateName});

  @override
  ConsumerState<MaterialSaveSheet> createState() => _MaterialSaveSheetState();
}

class _MaterialSaveSheetState extends ConsumerState<MaterialSaveSheet> {
  final TextEditingController _memoController = TextEditingController();

  /// null이면 아직 카테고리 목록을 받지 못해 기본 선택이 정해지지 않은 상태.
  String? _selectedCategory;
  bool _isSaving = false;

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _save(MaterialResource resource) async {
    final String? category = _selectedCategory;
    if (category == null) return;

    setState(() => _isSaving = true);
    await ref
        .read(materialRepositoryProvider)
        .saveMaterial(
          resource: resource,
          category: category,
          memo: _memoController.text.trim(),
        );
    if (!mounted) return;
    Navigator.of(context).pop(resource.title);
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: AppTextStyle.subText.copyWith(fontSize: 13)),
    );
  }

  Widget _form(MaterialSaveData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ResourcePreviewCard(resource: data.resource),
        const SizedBox(height: AppSpacing.space3),
        _label('메모 추가 (선택)'),
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
        _label('카테고리'),
        Wrap(
          spacing: AppSpacing.space1,
          runSpacing: AppSpacing.space1,
          children: [
            for (final category in data.categories)
              CustomBadge(
                field: category,
                compact: true,
                selected: _selectedCategory == category,
                onTap: () => setState(() => _selectedCategory = category),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<MaterialSaveData> dataAsync = ref.watch(
      materialSaveDataProvider(widget.certificateName),
    );
    final MaterialSaveData? data = dataAsync.value;
    // 목록이 처음 도착한 시점에 첫 카테고리(해당 자격증)를 기본 선택으로 둔다.
    // 이후에는 사용자의 선택을 그대로 유지한다.
    if (data != null &&
        _selectedCategory == null &&
        data.categories.isNotEmpty) {
      _selectedCategory = data.categories.first;
    }

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
            // 키보드가 올라오거나 내용이 길어져도 시트가 상태바 아래까지
            // 차오르지 않도록 제한한다. 넘치는 내용은 안쪽 Flexible +
            // SingleChildScrollView가 스크롤로 처리한다.
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          child: Padding(
            // 키보드가 올라온 만큼 시트를 밀어 올려 입력창이 가리지 않게 한다.
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space4,
              ),
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
                      Text('자료방에 저장', style: AppTextStyle.section),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        behavior: HitTestBehavior.opaque,
                        child: const Icon(Icons.close, color: AppColors.text),
                      ),
                    ],
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(top: AppSpacing.space3),
                      child: dataAsync.when(
                        data: _form,
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
                          child: Text(
                            '자료를 불러오지 못했어요',
                            style: AppTextStyle.subText,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 14,
                      bottom: AppSpacing.space4,
                    ),
                    child: CustomElevatedButton(
                      text: '저장',
                      backgroundColor: AppColors.primary,
                      onPressed: data == null || _isSaving
                          ? null
                          : () => _save(data.resource),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
