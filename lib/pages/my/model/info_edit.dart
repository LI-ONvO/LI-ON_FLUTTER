import 'package:json_annotation/json_annotation.dart';
import 'package:li_on/core/model/job_field.dart';

part 'info_edit.g.dart';

@JsonSerializable(createFactory: false)
class InfoEditRequest {
  final String nickname;
  final int jobId;

  const InfoEditRequest({required this.nickname, required this.jobId});

  Map<String, dynamic> toJson() => _$InfoEditRequestToJson(this);
}

@JsonSerializable(createToJson: false)
class InfoEditResponse {
  final int id;
  final String nickname;
  final JobField job;

  const InfoEditResponse({
    required this.id,
    required this.nickname,
    required this.job,
  });

  factory InfoEditResponse.fromJson(Map<String, dynamic> json) =>
      _$InfoEditResponseFromJson(json);
}
