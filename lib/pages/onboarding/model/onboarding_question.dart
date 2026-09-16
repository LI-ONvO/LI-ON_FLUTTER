import 'package:json_annotation/json_annotation.dart';

part 'onboarding_question.g.dart';

/// `GET /api/onboarding/questions` 응답의 선택지 한 건.
@JsonSerializable()
class OnboardingQuestionOption {
  final String key;
  final String value;
  final String label;

  const OnboardingQuestionOption({
    required this.key,
    required this.value,
    required this.label,
  });

  factory OnboardingQuestionOption.fromJson(Map<String, dynamic> json) =>
      _$OnboardingQuestionOptionFromJson(json);

  Map<String, dynamic> toJson() => _$OnboardingQuestionOptionToJson(this);
}

/// `GET /api/onboarding/questions` 응답의 질문 한 건.
@JsonSerializable()
class OnboardingQuestion {
  final int id;

  /// 답변 제출(`POST /api/users/me/onboarding`) 시 `questionKey`로 그대로 사용한다.
  final String key;

  final String title;

  /// 선택해야 하는 최소·최대 개수. `minSelect`가 0이면 건너뛸 수 있는 질문이다.
  final int minSelect;
  final int maxSelect;

  final List<OnboardingQuestionOption> options;

  const OnboardingQuestion({
    required this.id,
    required this.key,
    required this.title,
    required this.minSelect,
    required this.maxSelect,
    required this.options,
  });

  factory OnboardingQuestion.fromJson(Map<String, dynamic> json) =>
      _$OnboardingQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$OnboardingQuestionToJson(this);
}
