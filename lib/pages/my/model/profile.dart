import 'package:json_annotation/json_annotation.dart';
import 'package:li_on/core/model/job_field.dart';

part 'profile.g.dart';

/// `GET /api/users/me` 응답. 명세서 기준 필드는 `id·email·nickname·
/// isOnboarded·desiredFields`이며, 직무(job) 개념은 명세에서 제외됐다.
@JsonSerializable()
class Profile {
  final int id;
  final String email;
  final String nickname;
  final List<JobField> desiredFields;
  final bool isOnboarded;

  const Profile({
    required this.id,
    required this.email,
    required this.nickname,
    required this.desiredFields,
    required this.isOnboarded,
  });

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
