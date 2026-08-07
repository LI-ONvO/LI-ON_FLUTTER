import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/badge/custom_badge.dart';
import 'package:li_on/core/widgets/button/custom_elevated_button.dart';
import 'package:li_on/core/widgets/layout/base_scaffold.dart';
import 'package:li_on/pages/onboarding/provider/onboarding_view_model.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingState state = ref.watch(onboardingViewModelProvider);
    final OnboardingViewModel viewModel = ref.read(
      onboardingViewModelProvider.notifier,
    );

    return BaseScaffold(
      appBar: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.space5),
          Text(
            '어떤 분야에 관심이 있나요?',
            style: AppTextStyle.semiBold.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            '복수 선택 가능해요',
            style: AppTextStyle.subText.copyWith(fontSize: 15),
          ),
          const SizedBox(height: AppSpacing.space3),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: AppSpacing.space1,
                runSpacing: AppSpacing.space1,
                children: [
                  for (final field in onboardingFields)
                    CustomBadge(
                      field: field,
                      selected: state.selectedFields.contains(field),
                      onTap: () => viewModel.toggleField(field),
                    ),
                ],
              ),
            ),
          ),
          CustomElevatedButton(
            onPressed: state.isFilled ? () {} : null,
            text: '다음',
            backgroundColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
