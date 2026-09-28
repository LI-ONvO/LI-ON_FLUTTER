import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/core/auth/auth_session.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/network/api_exception.dart';
import 'package:li_on/core/widgets/badge/custom_badge.dart';
import 'package:li_on/core/widgets/button/custom_elevated_button.dart';
import 'package:li_on/core/widgets/layout/base_scaffold.dart';
import 'package:li_on/features/certificate_search/presentation/view_models/certificate_recommendation_view_model.dart';
import 'package:li_on/features/my/data/profile.dart';
import 'package:li_on/features/my/data/user_repository.dart';
import 'package:li_on/features/onboarding/data/onboarding_question.dart';
import 'package:li_on/features/onboarding/data/onboarding_repository.dart';
import 'package:li_on/features/onboarding/data/onboarding_submit_result.dart';
import 'package:li_on/features/onboarding/presentation/view_models/onboarding_view_model.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<OnboardingQuestion>> questionsAsync = ref.watch(
      onboardingQuestionsProvider,
    );

    return BaseScaffold(
      appBar: null,
      child: questionsAsync.when(
        data: (questions) => _OnboardingForm(questions: questions),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _RetryError(
          message: '질문을 불러오지 못했어요',
          onRetry: () => ref.invalidate(onboardingQuestionsProvider),
        ),
      ),
    );
  }
}

class _OnboardingForm extends ConsumerStatefulWidget {
  const _OnboardingForm({required this.questions});

  final List<OnboardingQuestion> questions;

  @override
  ConsumerState<_OnboardingForm> createState() => _OnboardingFormState();
}

class _OnboardingFormState extends ConsumerState<_OnboardingForm> {
  List<OnboardingQuestion> get questions => widget.questions;

  @override
  void initState() {
    super.initState();
    _prefillFromProfile();
  }

  /// 마이페이지에서 다시 들어온 경우(이미 로그인) 서버에 저장된 희망 분야를
  /// 미리 선택해 둔다. 회원가입 직후 온보딩은 아직 답이 없으니 건너뛰고,
  /// 프로필을 못 불러와도 빈 채로 시작할 뿐이라 오류는 무시한다.
  Future<void> _prefillFromProfile() async {
    if (!ref.read(authSessionProvider).isAuthenticated) return;
    try {
      final Profile profile = await ref.read(myProfileProvider.future);
      if (!mounted) return;
      ref
          .read(onboardingSelectionViewModelProvider.notifier)
          .prefillDesiredFields(questions, profile.desiredFields);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<OnboardingSubmitResult?>>(
      onboardingSubmitViewModelProvider,
      (previous, next) {
        if (!next.hasValue || next.value == null) return;
        final AuthSessionController authSession = ref.read(authSessionProvider);
        // 마이페이지에서 다시 들어온 경우(이미 로그인)엔 마이페이지로,
        // 회원가입 직후라면 가입 때 받아 둔 토큰으로 바로 로그인 상태로
        // 바꿔 탐색 화면으로 보낸다. 둘 다 아니면(토큰 없이 들어온 예외
        // 상황) 로그인 화면으로 보낸다.
        // context.pop()은 이 리스너(비동기 상태 변화 콜백)에서 호출하면
        // 라우터가 실제로 이동하지 않는 경우가 있어 go()로 목적지를
        // 명시한다.
        final bool wasAlreadySignedIn = authSession.isAuthenticated;
        authSession.finishOnboarding();
        final bool isSignedIn = authSession.isAuthenticated;
        // 희망 분야가 바뀌었으니 추천을 새로 만든다. GET은 서버에 저장된
        // 예전 추천(빈 목록일 수도 있음)을 그대로 돌려줄 뿐이라 invalidate
        // 만으로는 바뀐 답이 반영되지 않는다.
        if (isSignedIn) {
          ref.read(certificateRecommendationsProvider.notifier).generate();
        } else {
          ref.invalidate(certificateRecommendationsProvider);
        }
        ref.invalidate(myProfileProvider);
        if (wasAlreadySignedIn) {
          context.go('/profile');
        } else if (isSignedIn) {
          context.go('/search');
        } else {
          context.go('/login');
        }
      },
    );

    final OnboardingSelectionState selection = ref.watch(
      onboardingSelectionViewModelProvider,
    );
    final OnboardingSelectionViewModel selectionViewModel = ref.read(
      onboardingSelectionViewModelProvider.notifier,
    );
    final AsyncValue<OnboardingSubmitResult?> submitState = ref.watch(
      onboardingSubmitViewModelProvider,
    );

    final bool isFilled = questions.every((question) {
      if (question.minSelect <= 0) return true;
      return selection.selectionsFor(question.key).length >= question.minSelect;
    });
    final bool isSubmitting = submitState.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.space5),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final question in questions) ...[
                  Text(
                    question.title,
                    style: AppTextStyle.semiBold.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  Wrap(
                    spacing: AppSpacing.space1,
                    runSpacing: AppSpacing.space1,
                    children: [
                      for (final option in question.options)
                        CustomBadge(
                          field: option.label,
                          selected: selection
                              .selectionsFor(question.key)
                              .contains(option.value),
                          onTap: () => selectionViewModel.toggleOption(
                            question,
                            option.value,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space5),
                ],
              ],
            ),
          ),
        ),
        if (submitState.hasError)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space2),
            child: Text(
              submitState.error is ApiException
                  ? (submitState.error as ApiException).message
                  : '제출하지 못했어요. 다시 시도해주세요',
              style: AppTextStyle.subText.copyWith(color: AppColors.danger),
            ),
          ),
        CustomElevatedButton(
          onPressed: isFilled && !isSubmitting
              ? () => ref
                    .read(onboardingSubmitViewModelProvider.notifier)
                    .submit(questions)
              : null,
          text: '다음',
          backgroundColor: AppColors.primary,
        ),
      ],
    );
  }
}

class _RetryError extends StatelessWidget {
  const _RetryError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: AppTextStyle.subText),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}
