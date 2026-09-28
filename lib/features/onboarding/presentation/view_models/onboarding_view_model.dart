import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/features/onboarding/data/onboarding_question.dart';
import 'package:li_on/features/onboarding/data/onboarding_repository.dart';
import 'package:li_on/features/onboarding/data/onboarding_submit_result.dart';

/// 질문 key별로 선택한 옵션 [OnboardingQuestionOption.value] 집합.
class OnboardingSelectionState {
  final Map<String, Set<String>> selectedByQuestionKey;

  const OnboardingSelectionState({this.selectedByQuestionKey = const {}});

  Set<String> selectionsFor(String questionKey) =>
      selectedByQuestionKey[questionKey] ?? const {};

  OnboardingSelectionState copyWith({
    Map<String, Set<String>>? selectedByQuestionKey,
  }) {
    return OnboardingSelectionState(
      selectedByQuestionKey:
          selectedByQuestionKey ?? this.selectedByQuestionKey,
    );
  }
}

class OnboardingSelectionViewModel extends Notifier<OnboardingSelectionState> {
  @override
  OnboardingSelectionState build() => const OnboardingSelectionState();

  void toggleOption(OnboardingQuestion question, String optionValue) {
    final Set<String> current = Set<String>.from(
      state.selectionsFor(question.key),
    );
    if (!current.remove(optionValue)) {
      // 최대 선택 개수에 도달했으면 새 선택을 무시한다.
      if (question.maxSelect > 0 && current.length >= question.maxSelect) {
        return;
      }
      current.add(optionValue);
    }
    state = state.copyWith(
      selectedByQuestionKey: {
        ...state.selectedByQuestionKey,
        question.key: current,
      },
    );
  }
}

final onboardingSelectionViewModelProvider = NotifierProvider<
  OnboardingSelectionViewModel,
  OnboardingSelectionState
>(OnboardingSelectionViewModel.new);

/// 답변 제출 액션. 성공하면 [OnboardingSubmitResult]를 담는다.
class OnboardingSubmitViewModel
    extends AsyncNotifier<OnboardingSubmitResult?> {
  @override
  Future<OnboardingSubmitResult?> build() async => null;

  Future<void> submit(List<OnboardingQuestion> questions) async {
    final OnboardingSelectionState selection = ref.read(
      onboardingSelectionViewModelProvider,
    );
    final List<OnboardingAnswer> answers = [
      for (final question in questions)
        OnboardingAnswer(
          questionKey: question.key,
          optionValues: selection.selectionsFor(question.key).toList(),
        ),
    ];
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(onboardingRepositoryProvider).submitAnswers(answers),
    );
  }
}

final onboardingSubmitViewModelProvider =
    AsyncNotifierProvider<OnboardingSubmitViewModel, OnboardingSubmitResult?>(
      OnboardingSubmitViewModel.new,
    );
