import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/core/model/job_field.dart';
import 'package:li_on/features/onboarding/data/onboarding_question.dart';
import 'package:li_on/features/onboarding/presentation/view_models/onboarding_view_model.dart';

OnboardingQuestion _question({
  String key = 'interestedField',
  int maxSelect = 3,
}) {
  return OnboardingQuestion(
    id: 1,
    key: key,
    title: '어떤 분야에 관심이 있나요?',
    minSelect: 1,
    maxSelect: maxSelect,
    options: const [
      OnboardingQuestionOption(key: 'it', value: 'IT', label: 'IT·정보통신'),
      OnboardingQuestionOption(key: 'biz', value: 'BIZ', label: '경영·회계'),
    ],
  );
}

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  test('초기 상태는 선택된 옵션이 없다', () {
    final OnboardingSelectionState state = container.read(
      onboardingSelectionViewModelProvider,
    );

    expect(state.selectionsFor('interestedField'), isEmpty);
  });

  test('옵션을 토글하면 선택 목록에 추가된다', () {
    final OnboardingSelectionViewModel viewModel = container.read(
      onboardingSelectionViewModelProvider.notifier,
    );
    final OnboardingQuestion question = _question();

    viewModel.toggleOption(question, 'IT');

    final OnboardingSelectionState state = container.read(
      onboardingSelectionViewModelProvider,
    );
    expect(state.selectionsFor(question.key), {'IT'});
  });

  test('같은 옵션을 다시 토글하면 선택이 해제된다', () {
    final OnboardingSelectionViewModel viewModel = container.read(
      onboardingSelectionViewModelProvider.notifier,
    );
    final OnboardingQuestion question = _question();

    viewModel.toggleOption(question, 'IT');
    viewModel.toggleOption(question, 'IT');

    final OnboardingSelectionState state = container.read(
      onboardingSelectionViewModelProvider,
    );
    expect(state.selectionsFor(question.key), isEmpty);
  });

  test('같은 질문 안에서 여러 옵션을 동시에 선택할 수 있다', () {
    final OnboardingSelectionViewModel viewModel = container.read(
      onboardingSelectionViewModelProvider.notifier,
    );
    final OnboardingQuestion question = _question();

    viewModel.toggleOption(question, 'IT');
    viewModel.toggleOption(question, 'BIZ');

    final OnboardingSelectionState state = container.read(
      onboardingSelectionViewModelProvider,
    );
    expect(state.selectionsFor(question.key), {'IT', 'BIZ'});
  });

  test('여러 옵션 중 하나만 해제해도 나머지 선택은 유지된다', () {
    final OnboardingSelectionViewModel viewModel = container.read(
      onboardingSelectionViewModelProvider.notifier,
    );
    final OnboardingQuestion question = _question();

    viewModel.toggleOption(question, 'IT');
    viewModel.toggleOption(question, 'BIZ');
    viewModel.toggleOption(question, 'IT');

    final OnboardingSelectionState state = container.read(
      onboardingSelectionViewModelProvider,
    );
    expect(state.selectionsFor(question.key), {'BIZ'});
  });

  test('최대 선택 개수에 도달하면 새 선택을 무시한다', () {
    final OnboardingSelectionViewModel viewModel = container.read(
      onboardingSelectionViewModelProvider.notifier,
    );
    final OnboardingQuestion question = _question(maxSelect: 1);

    viewModel.toggleOption(question, 'IT');
    viewModel.toggleOption(question, 'BIZ');

    final OnboardingSelectionState state = container.read(
      onboardingSelectionViewModelProvider,
    );
    expect(state.selectionsFor(question.key), {'IT'});
  });

  group('희망 분야 미리 선택', () {
    test('서버의 희망 분야와 이름이 같은 선택지를 미리 선택한다', () {
      final OnboardingSelectionViewModel viewModel = container.read(
        onboardingSelectionViewModelProvider.notifier,
      );
      final OnboardingQuestion question = _question();

      viewModel.prefillDesiredFields(
        [question],
        const [JobField(id: 7, name: '경영·회계')],
      );

      expect(
        container
            .read(onboardingSelectionViewModelProvider)
            .selectionsFor(question.key),
        {'BIZ'},
      );
    });

    test('이미 고른 답이 있는 질문은 덮어쓰지 않는다', () {
      final OnboardingSelectionViewModel viewModel = container.read(
        onboardingSelectionViewModelProvider.notifier,
      );
      final OnboardingQuestion question = _question();
      viewModel.toggleOption(question, 'IT');

      viewModel.prefillDesiredFields(
        [question],
        const [JobField(id: 7, name: '경영·회계')],
      );

      expect(
        container
            .read(onboardingSelectionViewModelProvider)
            .selectionsFor(question.key),
        {'IT'},
      );
    });

    test('이름이 맞는 선택지가 없는 질문은 비워 둔다', () {
      final OnboardingSelectionViewModel viewModel = container.read(
        onboardingSelectionViewModelProvider.notifier,
      );
      final OnboardingQuestion question = _question(key: 'studyTime');

      viewModel.prefillDesiredFields(
        [question],
        const [JobField(id: 7, name: '백엔드 개발')],
      );

      expect(
        container
            .read(onboardingSelectionViewModelProvider)
            .selectionsFor(question.key),
        isEmpty,
      );
    });

    test('최대 선택 개수를 넘겨 미리 선택하지 않는다', () {
      final OnboardingSelectionViewModel viewModel = container.read(
        onboardingSelectionViewModelProvider.notifier,
      );
      final OnboardingQuestion question = _question(maxSelect: 1);

      viewModel.prefillDesiredFields(
        [question],
        const [
          JobField(id: 1, name: 'IT·정보통신'),
          JobField(id: 2, name: '경영·회계'),
        ],
      );

      expect(
        container
            .read(onboardingSelectionViewModelProvider)
            .selectionsFor(question.key),
        hasLength(1),
      );
    });
  });
}
