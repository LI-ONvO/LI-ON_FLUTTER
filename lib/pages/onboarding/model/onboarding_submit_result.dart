import 'package:json_annotation/json_annotation.dart';
import 'package:li_on/core/model/job_field.dart';

part 'onboarding_submit_result.g.dart';

/// 구조화 저장되지 않는 기타 답변(binding=GENERIC).
@JsonSerializable()
class OnboardingCustomAnswer {
  final String questionKey;
  final String value;

  const OnboardingCustomAnswer({
    required this.questionKey,
    required this.value,
  });

  factory OnboardingCustomAnswer.fromJson(Map<String, dynamic> json) =>
      _$OnboardingCustomAnswerFromJson(json);

  Map<String, dynamic> toJson() => _$OnboardingCustomAnswerToJson(this);
}

/// `POST /api/users/me/onboarding` 응답.
@JsonSerializable()
class OnboardingSubmitResult {
  final bool isOnboarded;
  final JobField? job;

  @JsonKey(defaultValue: <JobField>[])
  final List<JobField> desiredFields;

  @JsonKey(defaultValue: <OnboardingCustomAnswer>[])
  final List<OnboardingCustomAnswer> customAnswers;

  const OnboardingSubmitResult({
    required this.isOnboarded,
    this.job,
    required this.desiredFields,
    required this.customAnswers,
  });

  factory OnboardingSubmitResult.fromJson(Map<String, dynamic> json) =>
      _$OnboardingSubmitResultFromJson(json);

  Map<String, dynamic> toJson() => _$OnboardingSubmitResultToJson(this);
}
