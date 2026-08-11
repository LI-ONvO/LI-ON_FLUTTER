import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:li_on/core/constants/color.dart';

part 'calendar_event.g.dart';

/// 일정의 성격. 캘린더에서 왼쪽 색 막대 색을 구분하는 데 쓴다.
enum CalendarEventCategory {
  study,
  exam;

  Color get accentColor => switch (this) {
    CalendarEventCategory.study => AppColors.primary,
    CalendarEventCategory.exam => AppColors.success,
  };
}

/// 일정 시작 전 알림을 보낼 시점.
enum CalendarReminder {
  none,
  minutes5,
  minutes10,
  minutes30,
  hour1,
  day1;

  String get label => switch (this) {
    CalendarReminder.none => '없음',
    CalendarReminder.minutes5 => '5분 전',
    CalendarReminder.minutes10 => '10분 전',
    CalendarReminder.minutes30 => '30분 전',
    CalendarReminder.hour1 => '1시간 전',
    CalendarReminder.day1 => '1일 전',
  };
}

/// 캘린더에 표시되는 일정 한 건.
@JsonSerializable()
class CalendarEvent {
  final String id;
  final String title;
  final DateTime startAt;
  final DateTime endAt;
  final CalendarEventCategory category;
  final CalendarReminder reminder;
  final String? linkedCertificate;
  final String? memo;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.startAt,
    required this.endAt,
    this.category = CalendarEventCategory.study,
    this.reminder = CalendarReminder.none,
    this.linkedCertificate,
    this.memo,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventFromJson(json);

  Map<String, dynamic> toJson() => _$CalendarEventToJson(this);

  DateTime get startDate =>
      DateTime(startAt.year, startAt.month, startAt.day);

  DateTime get endDate => DateTime(endAt.year, endAt.month, endAt.day);

  /// [day]가 이 일정의 기간(날짜만 비교)에 포함되는지.
  bool occursOn(DateTime day) {
    final DateTime target = DateTime(day.year, day.month, day.day);
    return !target.isBefore(startDate) && !target.isAfter(endDate);
  }

  /// "7/20" 또는 여러 날에 걸치면 "7/20 ~ 7/27" 형식.
  /// intl 의존성이 없어 직접 포맷한다.
  String get dateRangeLabel {
    final String start = '${startAt.month}/${startAt.day}';
    if (startDate == endDate) return start;
    return '$start ~ ${endAt.month}/${endAt.day}';
  }

  /// "오후 7:00" 형식의 시작 시각 표기.
  String get timeLabel => formatKoreanTime(startAt);
}

/// 오전/오후 12시간제 표기. intl 의존성이 없어 직접 포맷한다.
String formatKoreanTime(DateTime time) {
  final bool isAm = time.hour < 12;
  final int hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final String minute = time.minute.toString().padLeft(2, '0');
  return '${isAm ? '오전' : '오후'} $hour12:$minute';
}

/// [formatKoreanTime]의 [TimeOfDay] 버전.
String formatKoreanTimeOfDay(TimeOfDay time) {
  return formatKoreanTime(DateTime(2000, 1, 1, time.hour, time.minute));
}
