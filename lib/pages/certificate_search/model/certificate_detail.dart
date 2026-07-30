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
}

class CertificateField {
  final int id;
  final String name;

  const CertificateField({required this.id, required this.name});
}

class CertificateDetail {
  // 실제 API 응답 필드
  final int id;
  final String name;
  final String issuingOrg;
  final String category;
  final String description;
  final String examInfo;
  final List<CertificateField> fields;

  // Figma 목업 전용 필드 (백엔드 응답에 아직 없음 — 추가되면 API 값으로 교체)
  final String level;
  final String examFee;

  /// 0~100 스케일의 합격률 (예: 42.3 = 42.3%). [ExamSubject.percent]와 달리
  /// 0-1 스케일이 아니므로 혼동하지 않도록 주의한다.
  final double passRate;
  final String examDuration;
  final List<ExamSubject> subjects;

  const CertificateDetail({
    required this.id,
    required this.name,
    required this.issuingOrg,
    required this.category,
    required this.description,
    required this.examInfo,
    required this.fields,
    required this.level,
    required this.examFee,
    required this.passRate,
    required this.examDuration,
    required this.subjects,
  });

  /// 과목 수는 [subjects]로부터 파생시켜, 하드코딩된 값이 실제 과목 목록과
  /// 어긋나는 일이 없도록 한다.
  int get subjectCount => subjects.length;
}
