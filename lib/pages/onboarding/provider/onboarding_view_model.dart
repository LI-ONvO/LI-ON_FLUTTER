import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';

const List<String> onboardingFields = [
  'IT·정보통신',
  '경영·회계',
  '건축·토목',
  '보건·의료',
  '교육',
  '디자인',
  '법률·행정',
  '기계·전기',
];

class OnboardingState {
  final Set<String> selectedFields;

  const OnboardingState({this.selectedFields = const {}});

  bool get isFilled => selectedFields.isNotEmpty;

  OnboardingState copyWith({Set<String>? selectedFields}) {
    return OnboardingState(
      selectedFields: selectedFields == null
          ? this.selectedFields
          : UnmodifiableSetView(selectedFields),
    );
  }
}

class OnboardingViewModel extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void toggleField(String field) {
    final Set<String> updated = Set<String>.from(state.selectedFields);
    if (!updated.remove(field)) {
      updated.add(field);
    }
    state = state.copyWith(selectedFields: updated);
  }
}

final onboardingViewModelProvider =
    NotifierProvider<OnboardingViewModel, OnboardingState>(
      OnboardingViewModel.new,
    );
