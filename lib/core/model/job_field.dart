import 'package:json_annotation/json_annotation.dart';

part 'job_field.g.dart';

@JsonSerializable()
class JobField {
  final int id;
  final String name;

  const JobField({required this.id, required this.name});

  factory JobField.fromJson(Map<String, dynamic> json) =>
      _$JobFieldFromJson(json);

  Map<String, dynamic> toJson() => _$JobFieldToJson(this);
}
