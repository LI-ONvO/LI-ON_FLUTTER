/// 서버가 UTC(`...Z`)로 주는 시각 문자열을 기기 로컬 시간으로 바꿔 파싱한다.
/// 날짜별 분류·시각 표시가 사용자 시간대 기준이 되도록 모델의
/// `@JsonKey(fromJson:)`에서 사용한다.
DateTime localDateTimeFromJson(String value) => DateTime.parse(value).toLocal();
