import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/pages/roadmap/calendar_add/model/calendar_schedule.dart';

/// 로드맵 대화에서 추출한 추천 일정 더미 데이터.
/// 실제로는 대화 내용을 분석한 결과가 내려온다.
List<CalendarSchedule> _dummySchedules(String certificateName) {
  return [
    CalendarSchedule(
      id: '1',
      title: '$certificateName 필기 - 1과목 학습',
      startDate: DateTime(2026, 7, 20),
      endDate: DateTime(2026, 7, 27),
    ),
    CalendarSchedule(
      id: '2',
      title: '$certificateName 필기 - 2과목 학습',
      startDate: DateTime(2026, 7, 28),
      endDate: DateTime(2026, 8, 3),
    ),
    CalendarSchedule(
      id: '3',
      title: '$certificateName 필기 모의고사',
      startDate: DateTime(2026, 8, 4),
      endDate: DateTime(2026, 8, 5),
      defaultSelected: false,
    ),
  ];
}

/// 캘린더에 추가할 일정을 가져오고 저장하는 방법을 추상화한다.
/// API 연동 시에는 이 인터페이스를 구현하는 클래스를 새로 만들고
/// [calendarRepositoryProvider]의 구현체만 교체하면 된다.
abstract class CalendarRepository {
  /// 해당 자격증의 로드맵 대화에서 추천된 일정 목록.
  Future<List<CalendarSchedule>> fetchSuggestedSchedules(
    String certificateName,
  );

  /// 선택한 일정을 캘린더에 저장한다.
  Future<void> addSchedules(List<CalendarSchedule> schedules);
}

/// 실제 캘린더 API가 준비되기 전까지 사용하는 더미 구현체.
class DummyCalendarRepository implements CalendarRepository {
  const DummyCalendarRepository();

  @override
  Future<List<CalendarSchedule>> fetchSuggestedSchedules(
    String certificateName,
  ) async {
    return _dummySchedules(certificateName);
  }

  @override
  Future<void> addSchedules(List<CalendarSchedule> schedules) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return const DummyCalendarRepository();
});

/// [certificateName]의 로드맵 대화에서 추천된 일정 목록.
final suggestedSchedulesProvider = FutureProvider.autoDispose
    .family<List<CalendarSchedule>, String>((ref, certificateName) {
      return ref
          .watch(calendarRepositoryProvider)
          .fetchSuggestedSchedules(certificateName);
    });
