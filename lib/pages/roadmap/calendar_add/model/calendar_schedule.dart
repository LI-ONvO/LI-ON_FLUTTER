import 'package:json_annotation/json_annotation.dart';

part 'calendar_schedule.g.dart';

/// 로드맵 대화에서 뽑아낸, 캘린더에 추가할 수 있는 학습 일정 한 건.
@JsonSerializable()
class CalendarSchedule {
  final String id;

  final String title;

  final DateTime startDate;

  /// 일정이 끝나는 날. 하루짜리 일정이면 [startDate]와 같다.
  final DateTime endDate;

  /// 챗봇이 기본으로 체크해 둘 일정인지 여부.
  /// 사용자가 시트에서 자유롭게 켜고 끌 수 있다.
  final bool defaultSelected;

  const CalendarSchedule({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.defaultSelected = true,
  });

  factory CalendarSchedule.fromJson(Map<String, dynamic> json) =>
      _$CalendarScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$CalendarScheduleToJson(this);

  bool get isSingleDay =>
      startDate.year == endDate.year &&
      startDate.month == endDate.month &&
      startDate.day == endDate.day;

  /// "7/20 ~ 7/27" 형식의 기간 표기. intl 의존성이 없어 직접 포맷한다.
  String get periodLabel {
    final String start = '${startDate.month}/${startDate.day}';
    if (isSingleDay) return start;
    return '$start ~ ${endDate.month}/${endDate.day}';
  }
}
