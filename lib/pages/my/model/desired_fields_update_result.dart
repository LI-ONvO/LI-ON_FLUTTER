import 'package:json_annotation/json_annotation.dart';
import 'package:li_on/core/model/job_field.dart';

part 'desired_fields_update_result.g.dart';

/// `PUT /api/users/me/desired-fields` 응답.
@JsonSerializable()
class DesiredFieldsUpdateResult {
  final List<JobField> desiredFields;

  const DesiredFieldsUpdateResult({required this.desiredFields});

  factory DesiredFieldsUpdateResult.fromJson(Map<String, dynamic> json) =>
      _$DesiredFieldsUpdateResultFromJson(json);

  Map<String, dynamic> toJson() => _$DesiredFieldsUpdateResultToJson(this);
}
