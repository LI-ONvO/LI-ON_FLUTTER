import 'package:json_annotation/json_annotation.dart';

part 'info_edit.g.dart';

/// `PATCH /api/users/me` 요청. 명세서 기준 수정 가능한 값은 `nickname`뿐이다.
@JsonSerializable(createFactory: false)
class InfoEditRequest {
  final String nickname;

  const InfoEditRequest({required this.nickname});

  Map<String, dynamic> toJson() => _$InfoEditRequestToJson(this);
}

/// `PATCH /api/users/me` 응답: `{ id, nickname }`.
@JsonSerializable(createToJson: false)
class InfoEditResponse {
  final int id;
  final String nickname;

  const InfoEditResponse({required this.id, required this.nickname});

  factory InfoEditResponse.fromJson(Map<String, dynamic> json) =>
      _$InfoEditResponseFromJson(json);
}
