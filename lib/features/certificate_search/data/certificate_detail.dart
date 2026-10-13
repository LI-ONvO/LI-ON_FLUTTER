import 'package:json_annotation/json_annotation.dart';
import 'package:li_on/core/utils/json_converters.dart';

part 'certificate_detail.g.dart';

/// 회차 한 건의 필기(document)·실기(practical) 접수/시험/발표 일정.
@JsonSerializable()
class ExamSchedule {
  /// 시행 연도. 서버가 숫자·숫자 문자열을 섞어 내려줘 [looseIntFromJson]으로 받는다.
  @JsonKey(fromJson: looseIntFromJson)
  final int implYy;

  /// 시행 회차. 위와 같은 이유로 [looseIntFromJson]을 쓴다.
  @JsonKey(fromJson: looseIntFromJson)
  final int implSeq;

  /// 아래 일정 필드는 필기만(또는 실기만) 있거나 아직 일정이 정해지지 않은
  /// 회차에서 서버가 `null`로 내려주므로 모두 nullable이다.
  final DateTime? docRegStartDt;
  final DateTime? docRegEndDt;
  final DateTime? docExamStartDt;
  final DateTime? docExamEndDt;
  final DateTime? docPassDt;

  final DateTime? pracRegStartDt;
  final DateTime? pracRegEndDt;
  final DateTime? pracExamStartDt;
  final DateTime? pracExamEndDt;
  final DateTime? pracPassDt;

  const ExamSchedule({
    required this.implYy,
    required this.implSeq,
    this.docRegStartDt,
    this.docRegEndDt,
    this.docExamStartDt,
    this.docExamEndDt,
    this.docPassDt,
    this.pracRegStartDt,
    this.pracRegEndDt,
    this.pracExamStartDt,
    this.pracExamEndDt,
    this.pracPassDt,
  });

  factory ExamSchedule.fromJson(Map<String, dynamic> json) =>
      _$ExamScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$ExamScheduleToJson(this);
}

/// `GET /api/certificates/{jmCd}` 응답.
@JsonSerializable()
class CertificateDetail {
  @JsonKey(name: 'jmCd')
  final String id;
  final String name;

  /// 분류가 없는 자격증은 `null`로 오므로 빈 문자열로 받는다.
  @JsonKey(defaultValue: '')
  final String category;

  /// 자격구분코드(T·S·W·C). 값 의미는 [qualGbLabel] 참고.
  @JsonKey(defaultValue: '')
  final String qualGbCd;

  /// 값이 없을 때 키가 빠지는 대신 `null`로 오는 경우가 있어 기본값을 둔다.
  @JsonKey(defaultValue: '')
  final String description;

  /// 필기 합격률(%). 예: 42.5. 데이터가 없으면 `null`.
  final double? docPassRate;

  /// 실기 합격률(%). 예: 68.1. 데이터가 없으면 `null`.
  final double? pracPassRate;

  /// 필기 응시료(원). 데이터가 없으면 `null`.
  final int? docFee;

  /// 실기 응시료(원). 데이터가 없으면 `null`.
  final int? pracFee;

  @JsonKey(defaultValue: <ExamSchedule>[])
  final List<ExamSchedule> examSchedules;

  const CertificateDetail({
    required this.id,
    required this.name,
    required this.category,
    this.qualGbCd = '',
    this.description = '',
    this.docPassRate,
    this.pracPassRate,
    this.docFee,
    this.pracFee,
    this.examSchedules = const [],
  });

  /// 이름 외에 보여줄 값이 하나도 없으면 false.
  bool get hasContent =>
      category.isNotEmpty ||
      description.isNotEmpty ||
      docPassRate != null ||
      pracPassRate != null ||
      docFee != null ||
      pracFee != null ||
      examSchedules.isNotEmpty;

  factory CertificateDetail.fromJson(Map<String, dynamic> json) =>
      _$CertificateDetailFromJson(json);

  Map<String, dynamic> toJson() => _$CertificateDetailToJson(this);
}
