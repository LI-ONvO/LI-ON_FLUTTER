import 'package:json_annotation/json_annotation.dart';

part 'onboarding_question.g.dart';

/// 온보딩 질문의 응답 형태. 서버 값(`SINGLE_SELECT` 등)과 매핑된다.
enum OnboardingQuestionType {
  @JsonValue('SINGLE_SELECT')
  singleSelect,
  @JsonValue('MULTI_SELECT')
  multiSelect,
  @JsonValue('TEXT')
  text,
  @JsonValue('DATE')
  date,
}

@JsonSerializable()
class OnboardingQuestionOption {
  final String value;
  final String label;

  const OnboardingQuestionOption({required this.value, required this.label});

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
  final OnboardingQuestionType type;
  final bool required;

  /// 선택형이 아니면(TEXT/DATE) 빈 배열이다.
  final List<OnboardingQuestionOption> options;

  const OnboardingQuestion({
    required this.id,
    required this.key,
    required this.title,
    required this.type,
    required this.required,
    required this.options,
  });

  factory OnboardingQuestion.fromJson(Map<String, dynamic> json) =>
      _$OnboardingQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$OnboardingQuestionToJson(this);
}
