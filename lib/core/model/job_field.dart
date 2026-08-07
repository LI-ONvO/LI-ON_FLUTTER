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

/// 마이페이지 "직무 수정"에서 고를 수 있는 직무 목록 (백엔드 연동 전 임시 데이터).
const List<JobField> jobOptions = [
  JobField(id: 1, name: '백엔드 개발자'),
  JobField(id: 2, name: '프론트엔드 개발자'),
  JobField(id: 3, name: '데이터 분석가'),
  JobField(id: 4, name: '회계·재무 담당자'),
  JobField(id: 5, name: '건축 설계사'),
  JobField(id: 6, name: '간호사'),
];

/// 마이페이지 "희망 분야 수정"에서 고를 수 있는 분야 목록. 온보딩의
/// `onboardingFields`와 같은 명칭 체계를 사용한다.
const List<JobField> desiredFieldOptions = [
  JobField(id: 101, name: 'IT·정보통신'),
  JobField(id: 102, name: '경영·회계'),
  JobField(id: 103, name: '건축·토목'),
  JobField(id: 104, name: '보건·의료'),
  JobField(id: 105, name: '교육'),
  JobField(id: 106, name: '디자인'),
  JobField(id: 107, name: '법률·행정'),
  JobField(id: 108, name: '기계·전기'),
];
