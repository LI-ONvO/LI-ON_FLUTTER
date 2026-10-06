import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/features/onboarding/presentation/view_models/onboarding_view_model.dart';

/// 희망 분야 수정에 다시 들어갈 때 이전 입력과 제출 상태를 비운다.
void pushOnboardingForEdit(BuildContext context, WidgetRef ref) {
  ref.invalidate(onboardingSelectionViewModelProvider);
  ref.invalidate(onboardingSubmitViewModelProvider);
  context.push('/onboarding');
}
