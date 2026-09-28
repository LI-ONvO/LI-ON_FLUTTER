import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/model/job_field.dart';
import 'package:li_on/core/network/api_exception.dart';
import 'package:li_on/core/utils/validators.dart';
import 'package:li_on/core/widgets/badge/custom_badge.dart';
import 'package:li_on/core/widgets/button/custom_elevated_button.dart';
import 'package:li_on/core/widgets/snackbar/custom_snackbar.dart';
import 'package:li_on/core/widgets/text_field/custom_text_field.dart';
import 'package:li_on/features/certificate_search/presentation/view_models/certificate_recommendation_view_model.dart';
import 'package:li_on/features/my/data/info_edit.dart';
import 'package:li_on/features/my/data/user_repository.dart';

/// [CustomBottomSheet]의 저장 결과. 서버에 저장까지 끝난 이름과 희망
/// 분야를 호출한 화면으로 돌려줄 때 사용한다.
typedef ProfileEditResult = ({String name, List<JobField> desiredFields});

class CustomBottomSheet extends ConsumerStatefulWidget {
  final String name;
  final String email;
  final List<JobField> desiredFields;

  const CustomBottomSheet({
    super.key,
    required this.name,
    required this.email,
    required this.desiredFields,
  });

  @override
  ConsumerState<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends ConsumerState<CustomBottomSheet> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.name,
  );
  late final TextEditingController _emailController = TextEditingController(
    text: widget.email,
  );
  late final List<JobField> _desiredFields = List.of(widget.desiredFields);
  bool _isSaving = false;

  bool get _desiredFieldsChanged {
    final Set<int> before = {
      for (final field in widget.desiredFields) field.id,
    };
    final Set<int> after = {for (final field in _desiredFields) field.id};
    return before.length != after.length || !before.containsAll(after);
  }

  /// 바뀐 항목만 서버에 저장하고, 모두 성공하면 저장된 값으로 시트를 닫는다.
  /// 실패하면 시트를 연 채로 사유를 알려 다시 시도할 수 있게 한다.
  Future<void> _save() async {
    final String name = _nameController.text.trim();
    final String? nameError = Validators.nickname(name);
    if (nameError != null) {
      CustomSnackbar.show(
        context,
        message: nameError,
        type: SnackbarType.error,
      );
      return;
    }

    setState(() => _isSaving = true);
    final UserRepository repository = ref.read(userRepositoryProvider);
    final bool fieldsChanged = _desiredFieldsChanged;
    bool savedAnything = false;
    try {
      String savedName = widget.name;
      if (name != widget.name) {
        final InfoEditResponse response = await repository.updateInfo(
          InfoEditRequest(nickname: name),
        );
        savedName = response.nickname;
        savedAnything = true;
      }
      List<JobField> savedFields = widget.desiredFields;
      if (fieldsChanged) {
        final result = await repository.updateDesiredFields(
          _desiredFields.map((field) => field.id).toList(),
        );
        savedFields = result.desiredFields;
        savedAnything = true;
        // 희망 분야가 바뀌었으니 추천을 새로 만든다(onboarding_page.dart와 동일).
        ref.read(certificateRecommendationsProvider.notifier).generate();
      }
      if (!mounted) return;
      Navigator.of(
        context,
      ).pop<ProfileEditResult>((name: savedName, desiredFields: savedFields));
    } on ApiException catch (exception) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      CustomSnackbar.show(
        context,
        message: exception.message,
        type: SnackbarType.error,
      );
    } finally {
      // 일부만 저장되고 실패한 경우에도 화면이 서버 값과 어긋나지 않게 한다.
      if (savedAnything) ref.invalidate(myProfileProvider);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Widget _optionsSection({
    required String title,
    required List<JobField> options,
    required bool Function(JobField option) isSelected,
    required ValueChanged<JobField> onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.baseTextStyle.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppSpacing.space2),
        Wrap(
          spacing: AppSpacing.space1,
          runSpacing: AppSpacing.space1,
          children: [
            for (final option in options)
              CustomBadge(
                field: option.name,
                selected: isSelected(option),
                onTap: () => onToggle(option),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        // 옵션 목록이 늘어나 내용이 길어져도 시트가 상태바 아래까지 차오르지
        // 않도록 최대 높이를 제한한다. 넘치는 내용은 안쪽 Flexible +
        // SingleChildScrollView가 스크롤로 처리한다.
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
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
                  Text('내 정보 수정', style: AppTextStyle.section),
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
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.space4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.space3,
                    children: [
                      CustomTextField(
                        label: '이름',
                        hintText: '',
                        controller: _nameController,
                      ),
                      CustomTextField(
                        label: '이메일',
                        hintText: '',
                        controller: _emailController,
                        enabled: false,
                        fillColor: AppColors.surface,
                      ),
                      GestureDetector(
                        // 비밀번호 변경 화면이 아직 없어, 무반응 대신 준비
                        // 중임을 알린다.
                        onTap: () => CustomSnackbar.show(
                          context,
                          message: '아직 준비 중인 기능이에요',
                          type: SnackbarType.info,
                        ),
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '비밀번호 변경',
                              style: AppTextStyle.mainText.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_sharp,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.background),
                      _optionsSection(
                        title: '희망 분야 수정',
                        options: desiredFieldOptions,
                        isSelected: (option) => _desiredFields.any(
                          (field) => field.id == option.id,
                        ),
                        onToggle: (option) => setState(() {
                          if (!_desiredFields.any(
                            (field) => field.id == option.id,
                          )) {
                            _desiredFields.add(option);
                          } else {
                            _desiredFields.removeWhere(
                              (field) => field.id == option.id,
                            );
                          }
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.space2,
                  bottom: AppSpacing.space4,
                ),
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _nameController,
                  builder: (context, value, _) {
                    final bool canSave =
                        value.text.trim().isNotEmpty && !_isSaving;
                    return CustomElevatedButton(
                      text: _isSaving ? '저장 중...' : '저장',
                      backgroundColor: AppColors.primary,
                      onPressed: canSave ? _save : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
