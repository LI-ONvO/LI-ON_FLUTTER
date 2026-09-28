import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/model/job_field.dart';
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

  /// 서버가 내려준 희망 분야(프로필의 `desiredFields`)와 이름이 같은 선택지를
  /// 미리 선택한다. 마이페이지에서 다시 들어왔을 때 이전 답을 처음부터 다시
  /// 고르지 않아도 되게 하려는 것으로, 서버가 이전 답을 주는 건 희망
  /// 분야뿐이라 다른 질문은 건드리지 않는다. 이미 고른 답이 있는 질문은
  /// 사용자가 고른 값을 덮어쓰지 않는다.
  void prefillDesiredFields(
    List<OnboardingQuestion> questions,
    List<JobField> desiredFields,
  ) {
    final Set<String> fieldNames = {
      for (final field in desiredFields) field.name,
    };
    if (fieldNames.isEmpty) return;
    final Map<String, Set<String>> updated = {...state.selectedByQuestionKey};
    for (final question in questions) {
      if (state.selectionsFor(question.key).isNotEmpty) continue;
      final Iterable<String> matched = question.options
          .where((option) => fieldNames.contains(option.label))
          .map((option) => option.value);
      final Set<String> values = {
        ...(question.maxSelect > 0
            ? matched.take(question.maxSelect)
            : matched),
      };
      if (values.isNotEmpty) updated[question.key] = values;
    }
    state = state.copyWith(selectedByQuestionKey: updated);
  }
}

final onboardingSelectionViewModelProvider =
    NotifierProvider<OnboardingSelectionViewModel, OnboardingSelectionState>(
      OnboardingSelectionViewModel.new,
    );

/// 답변 제출 액션. 성공하면 [OnboardingSubmitResult]를 담는다.
class OnboardingSubmitViewModel extends AsyncNotifier<OnboardingSubmitResult?> {
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
