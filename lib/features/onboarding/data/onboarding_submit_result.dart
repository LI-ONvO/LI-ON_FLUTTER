import 'package:json_annotation/json_annotation.dart';
import 'package:li_on/core/model/job_field.dart';

part 'onboarding_submit_result.g.dart';

/// `POST /api/users/me/onboarding` 응답: `{ desiredFields: [{ id, name }] }`.
@JsonSerializable()
class OnboardingSubmitResult {
  @JsonKey(defaultValue: <JobField>[])
  final List<JobField> desiredFields;

  const OnboardingSubmitResult({required this.desiredFields});

  factory OnboardingSubmitResult.fromJson(Map<String, dynamic> json) =>
      _$OnboardingSubmitResultFromJson(json);

  Map<String, dynamic> toJson() => _$OnboardingSubmitResultToJson(this);
}
