import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/model/job_field.dart';
import 'package:li_on/core/widgets/badge/custom_badge.dart';
import 'package:li_on/core/widgets/button/custom_elevated_button.dart';
import 'package:li_on/core/widgets/text_field/custom_text_field.dart';

/// [CustomBottomSheet]의 저장 결과. 이름, 직무, 희망 분야를 편집한 값을
/// 호출한 화면으로 돌려줄 때 사용한다.
typedef ProfileEditResult = ({
  String name,
  JobField? job,
  List<JobField> desiredFields,
});

class CustomBottomSheet extends StatefulWidget {
  final String name;
  final String email;
  final JobField? job;
  final List<JobField> desiredFields;

  const CustomBottomSheet({
    super.key,
    required this.name,
    required this.email,
    required this.job,
    required this.desiredFields,
  });

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.name,
  );
  late final TextEditingController _emailController = TextEditingController(
    text: widget.email,
  );
  late JobField? _job = widget.job;
  late final List<JobField> _desiredFields = List.of(widget.desiredFields);

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
                        onTap: () {},
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
                        title: '직무 수정',
                        options: jobOptions,
                        isSelected: (option) => _job?.id == option.id,
                        onToggle: (option) => setState(
                          () => _job = _job?.id == option.id ? null : option,
                        ),
                      ),
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
                    final bool canSave = value.text.trim().isNotEmpty;
                    return CustomElevatedButton(
                      text: '저장',
                      backgroundColor: AppColors.primary,
                      onPressed: canSave
                          ? () => Navigator.of(context).pop((
                              name: _nameController.text.trim(),
                              job: _job,
                              desiredFields: _desiredFields,
                            ))
                          : null,
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
