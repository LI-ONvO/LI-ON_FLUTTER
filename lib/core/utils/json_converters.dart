/// 서버가 UTC(`...Z`)로 주는 시각 문자열을 기기 로컬 시간으로 바꿔 파싱한다.
/// 날짜별 분류·시각 표시가 사용자 시간대 기준이 되도록 모델의
/// `@JsonKey(fromJson:)`에서 사용한다.
DateTime localDateTimeFromJson(String value) => DateTime.parse(value).toLocal();

/// [localDateTimeFromJson]의 nullable 버전. 서버가 값을 `null`로 주거나 키를
/// 생략할 수 있는 시각 필드(예: 일정의 `endAt`)에서 쓴다.
DateTime? localDateTimeFromJsonNullable(String? value) =>
    (value == null) ? null : DateTime.parse(value).toLocal();

/// 숫자 필드를 숫자(`num`)와 숫자 문자열(`String`) 양쪽 다 받아들여 int로
/// 바꾼다. 일부 응답이 같은 개념의 필드를 엔드포인트마다 다른 타입으로
/// 내려줘(예: 자격증 API의 `implSeq`), 그런 필드의 `@JsonKey(fromJson:)`에서
/// 쓴다.
int looseIntFromJson(dynamic value) => switch (value) {
  num n => n.toInt(),
  String s => int.parse(s),
  _ => throw FormatException('숫자로 변환할 수 없는 값입니다: $value'),
};
