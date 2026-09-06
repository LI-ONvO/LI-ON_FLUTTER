import 'package:json_annotation/json_annotation.dart';
import 'package:li_on/core/utils/json_converters.dart';

part 'certificate_detail.g.dart';

@JsonSerializable()
class ExamSubject {
  final String name;

  /// 0.0~1.0 사이의 출제 비중 (예: 0.22 = 22%). [CertificateDetail.passRate]와
  /// 달리 0-100 스케일이 아니므로 혼동하지 않도록 주의한다.
  final double percent;

  const ExamSubject({required this.name, required this.percent})
    : assert(
        percent >= 0 && percent <= 1,
        'percent는 0.0~1.0 사이의 비율이어야 합니다 (0-100 스케일이 아님).',
      );

  factory ExamSubject.fromJson(Map<String, dynamic> json) =>
      _$ExamSubjectFromJson(json);

  Map<String, dynamic> toJson() => _$ExamSubjectToJson(this);
}

/// 회차 한 건의 필기(document)·실기(practical) 접수/시험/발표 일정.
@JsonSerializable()
class ExamSchedule {
  /// 시행 연도. 서버가 숫자·숫자 문자열을 섞어 내려줘 [looseIntFromJson]으로 받는다.
  @JsonKey(fromJson: looseIntFromJson)
  final int implYy;

  /// 시행 회차. 위와 같은 이유로 [looseIntFromJson]을 쓴다.
  @JsonKey(fromJson: looseIntFromJson)
  final int implSeq;

  final DateTime docRegStartDt;
  final DateTime docRegEndDt;
  final DateTime docExamStartDt;
  final DateTime docExamEndDt;
  final DateTime docPassDt;

  final DateTime pracRegStartDt;
  final DateTime pracRegEndDt;
  final DateTime pracExamStartDt;
  final DateTime pracExamEndDt;
  final DateTime pracPassDt;

  const ExamSchedule({
    required this.implYy,
    required this.implSeq,
    required this.docRegStartDt,
    required this.docRegEndDt,
    required this.docExamStartDt,
    required this.docExamEndDt,
    required this.docPassDt,
    required this.pracRegStartDt,
    required this.pracRegEndDt,
    required this.pracExamStartDt,
    required this.pracExamEndDt,
    required this.pracPassDt,
  });

  factory ExamSchedule.fromJson(Map<String, dynamic> json) =>
      _$ExamScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$ExamScheduleToJson(this);
}

@JsonSerializable()
class CertificateField {
  final int id;
  final String name;

  const CertificateField({required this.id, required this.name});

  factory CertificateField.fromJson(Map<String, dynamic> json) =>
      _$CertificateFieldFromJson(json);

  Map<String, dynamic> toJson() => _$CertificateFieldToJson(this);
}

@JsonSerializable()
class CertificateDetail {
  // 실제 API 응답 필드.
  // [Certificate]와 마찬가지로 식별자는 `jmCd`일 것으로 보고 맞췄다(목록
  // 응답에서 확인됨). 상세 응답에서도 실제로 `jmCd`로 오는지는 아직
  // 콘솔 로그로 확인 전이니, 상세 화면을 열어보고 파싱 에러가 나면 알려달라.
  @JsonKey(name: 'jmCd')
  final String id;
  final String name;

  // 상세 응답에도 없다(목록과 마찬가지). description은 값이 없을 때 키가
  // 아예 빠지는 게 아니라 `null`로 오는 경우가 확인됐다.
  @JsonKey(defaultValue: '')
  final String issuingOrg;

  final String category;

  @JsonKey(defaultValue: '')
  final String description;

  @JsonKey(defaultValue: '')
  final String examInfo;

  final List<CertificateField> fields;

  @JsonKey(defaultValue: <ExamSchedule>[])
  final List<ExamSchedule> examSchedules;

  // Figma 목업 전용 필드 (백엔드 응답에 아직 없음 — 추가되면 API 값으로 교체).
  // 응답에 없어도 파싱이 실패하지 않도록 기본값을 둔다.
  @JsonKey(defaultValue: '')
  final String level;

  @JsonKey(defaultValue: '')
  final String examFee;

  /// 0~100 스케일의 합격률 (예: 42.3 = 42.3%). [ExamSubject.percent]와 달리
  /// 0-1 스케일이 아니므로 혼동하지 않도록 주의한다.
  @JsonKey(defaultValue: 0)
  final double passRate;

  @JsonKey(defaultValue: '')
  final String examDuration;

  @JsonKey(defaultValue: <ExamSubject>[])
  final List<ExamSubject> subjects;

  const CertificateDetail({
    required this.id,
    required this.name,
    this.issuingOrg = '',
    required this.category,
    this.description = '',
    this.examInfo = '',
    required this.fields,
    this.examSchedules = const [],
    required this.level,
    required this.examFee,
    required this.passRate,
    required this.examDuration,
    required this.subjects,
  });

  factory CertificateDetail.fromJson(Map<String, dynamic> json) =>
      _$CertificateDetailFromJson(json);

  Map<String, dynamic> toJson() => _$CertificateDetailToJson(this);

  /// 과목 수는 [subjects]로부터 파생시켜, 하드코딩된 값이 실제 과목 목록과
  /// 어긋나는 일이 없도록 한다.
  int get subjectCount => subjects.length;
}
