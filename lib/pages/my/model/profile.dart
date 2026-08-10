import 'package:json_annotation/json_annotation.dart';
import 'package:li_on/core/model/job_field.dart';

part 'profile.g.dart';

@JsonSerializable()
class Profile {
  final int id;
  final String email;
  final String nickname;
  final JobField? job;
  final List<JobField> desiredFields;
  final bool isOnboarded;

  const Profile({
    required this.id,
    required this.email,
    required this.nickname,
    this.job,
    required this.desiredFields,
    required this.isOnboarded,
  });

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
