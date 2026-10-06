import 'package:li_on/features/calendar/data/calendar_event.dart';
import 'package:li_on/features/calendar/data/calendar_repository.dart';

/// 테스트에서 [InMemoryCalendarEventRepository]의 초기 상태로 쓰는 일정.
/// 이번 달 8·15·22일에 반복 학습 일정을, 15일에는 시험 일정을 함께 둔다.
List<CalendarEvent> _dummyEvents() {
  final DateTime now = DateTime.now();
  DateTime onDay(int day, int hour, int minute) =>
      DateTime(now.year, now.month, day, hour, minute);

  return [
    CalendarEvent(
      id: 1,
      title: '실기 로드맵 학습',
      startAt: onDay(8, 19, 0),
      endAt: onDay(8, 20, 0),
      reminder: CalendarReminder.minutes30,
    ),
    CalendarEvent(
      id: 2,
      title: '실기 로드맵 학습',
      startAt: onDay(15, 19, 0),
      endAt: onDay(15, 20, 0),
      reminder: CalendarReminder.minutes30,
    ),
    CalendarEvent(
      id: 3,
      title: '정보처리기사 필기시험',
      startAt: onDay(15, 9, 0),
      endAt: onDay(15, 10, 0),
      reminder: CalendarReminder.hour1,
    ),
    CalendarEvent(
      id: 4,
      title: '실기 로드맵 학습',
      startAt: onDay(22, 19, 0),
      endAt: onDay(22, 20, 0),
      reminder: CalendarReminder.minutes30,
    ),
  ];
}

/// 네트워크 없이 테스트할 때 [calendarEventRepositoryProvider]에 덮어씌우는
/// 메모리 저장소. 프로덕션에서는 쓰지 않는다.
class InMemoryCalendarEventRepository implements CalendarEventRepository {
  /// 더미 목록을 그대로 쓰지 않고 복사해, 저장소를 새로 만들 때마다 같은
  /// 일정으로 시작하게 한다.
  final List<CalendarEvent> _events = [..._dummyEvents()];

  int _nextId = _dummyEvents().length + 1;

  @override
  Future<List<CalendarEvent>> fetchEvents() async {
    // 저장소 밖에서 목록을 직접 바꾸지 못하도록 복사본을 준다.
    return List.unmodifiable(_events);
  }

  @override
  Future<CalendarEvent> addEvent({
    required String title,
    required DateTime startAt,
    required DateTime endAt,
    required CalendarReminder reminder,
    int? roadmapStepId,
    String? description,
  }) async {
    final CalendarEvent event = CalendarEvent(
      id: _nextId++,
      title: title,
      startAt: startAt,
      endAt: endAt,
      reminder: reminder,
      roadmapStepId: roadmapStepId,
      description: description,
    );
    _events.add(event);
    return event;
  }

  @override
  Future<CalendarEvent> updateEvent(CalendarEvent event) async {
    final int index = _events.indexWhere((e) => e.id == event.id);
    if (index == -1) {
      throw StateError('일정을 찾을 수 없어요: ${event.id}');
    }
    _events[index] = event;
    return event;
  }

  @override
  Future<void> removeEvent(int id) async {
    _events.removeWhere((event) => event.id == id);
  }
}
