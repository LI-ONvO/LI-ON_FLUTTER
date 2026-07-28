import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/pages/onboarding/view_model/onboarding_view_model.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  test('초기 상태는 선택된 분야가 없다', () {
    final OnboardingState state = container.read(onboardingViewModelProvider);

    expect(state.selectedFields, isEmpty);
    expect(state.isFilled, isFalse);
  });

  test('필드를 토글하면 선택 목록에 추가된다', () {
    final OnboardingViewModel viewModel = container.read(
      onboardingViewModelProvider.notifier,
    );

    viewModel.toggleField('IT·정보통신');

    final OnboardingState state = container.read(onboardingViewModelProvider);
    expect(state.selectedFields, {'IT·정보통신'});
    expect(state.isFilled, isTrue);
  });

  test('같은 필드를 다시 토글하면 선택이 해제된다', () {
    final OnboardingViewModel viewModel = container.read(
      onboardingViewModelProvider.notifier,
    );

    viewModel.toggleField('IT·정보통신');
    viewModel.toggleField('IT·정보통신');

    final OnboardingState state = container.read(onboardingViewModelProvider);
    expect(state.selectedFields, isEmpty);
    expect(state.isFilled, isFalse);
  });

  test('여러 필드를 동시에 선택할 수 있다', () {
    final OnboardingViewModel viewModel = container.read(
      onboardingViewModelProvider.notifier,
    );

    viewModel.toggleField('IT·정보통신');
    viewModel.toggleField('경영·회계');

    final OnboardingState state = container.read(onboardingViewModelProvider);
    expect(state.selectedFields, {'IT·정보통신', '경영·회계'});
  });

  test('여러 필드 중 하나만 해제해도 나머지 선택은 유지된다', () {
    final OnboardingViewModel viewModel = container.read(
      onboardingViewModelProvider.notifier,
    );

    viewModel.toggleField('IT·정보통신');
    viewModel.toggleField('경영·회계');
    viewModel.toggleField('IT·정보통신');

    final OnboardingState state = container.read(onboardingViewModelProvider);
    expect(state.selectedFields, {'경영·회계'});
  });
}
