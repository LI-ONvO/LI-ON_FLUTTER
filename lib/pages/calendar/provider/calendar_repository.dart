import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/pages/calendar/model/calendar_event.dart';

/// 데모용으로 연결해두는 자격증. 실제로는 사용자가 학습 중인 자격증을 고르는
/// 기능이 생기면 그 값으로 대체한다.
const String dummyLinkedCertificate = '정보처리기사';

/// 캘린더를 처음 열었을 때 보이는 더미 일정. 이번 달 8·15·22일에 반복
/// 학습 일정을, 15일에는 시험 일정을 함께 둔다.
List<CalendarEvent> _dummyEvents() {
  final DateTime now = DateTime.now();
  DateTime onDay(int day, int hour, int minute) =>
      DateTime(now.year, now.month, day, hour, minute);

  return [
    CalendarEvent(
      id: '1',
      title: '실기 로드맵 학습',
      startAt: onDay(8, 19, 0),
      endAt: onDay(8, 19, 0),
      reminder: CalendarReminder.minutes30,
      linkedCertificate: dummyLinkedCertificate,
    ),
    CalendarEvent(
      id: '2',
      title: '실기 로드맵 학습',
      startAt: onDay(15, 19, 0),
      endAt: onDay(15, 19, 0),
      reminder: CalendarReminder.minutes30,
      linkedCertificate: dummyLinkedCertificate,
    ),
    CalendarEvent(
      id: '3',
      title: '정보처리기사 필기시험',
      startAt: onDay(15, 9, 0),
      endAt: onDay(15, 9, 0),
      category: CalendarEventCategory.exam,
      reminder: CalendarReminder.hour1,
      linkedCertificate: dummyLinkedCertificate,
    ),
    CalendarEvent(
      id: '4',
      title: '실기 로드맵 학습',
      startAt: onDay(22, 19, 0),
      endAt: onDay(22, 19, 0),
      reminder: CalendarReminder.minutes30,
      linkedCertificate: dummyLinkedCertificate,
    ),
  ];
}

/// 캘린더 일정을 읽고 쓰는 방법을 추상화한다.
/// API 연동 시에는 이 인터페이스를 구현하는 클래스를 새로 만들고
/// [calendarEventRepositoryProvider]의 구현체만 교체하면 된다.
abstract class CalendarEventRepository {
  Future<List<CalendarEvent>> fetchEvents();

  /// 일정을 저장하고, id가 부여된 일정을 돌려준다.
  Future<CalendarEvent> addEvent({
    required String title,
    required DateTime startAt,
    required DateTime endAt,
    required CalendarEventCategory category,
    required CalendarReminder reminder,
    String? linkedCertificate,
    String? memo,
  });
}

/// 실제 캘린더 API가 준비되기 전까지 사용하는 메모리 저장소.
/// 앱이 떠 있는 동안에만 유지되므로, 다시 실행하면 더미 데이터로 돌아간다.
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
    required CalendarEventCategory category,
    required CalendarReminder reminder,
    String? linkedCertificate,
    String? memo,
  }) async {
    final CalendarEvent event = CalendarEvent(
      id: '${_nextId++}',
      title: title,
      startAt: startAt,
      endAt: endAt,
      category: category,
      reminder: reminder,
      linkedCertificate: linkedCertificate,
      memo: memo,
    );
    _events.add(event);
    return event;
  }
}

/// 일정을 들고 있는 저장소. 앱 전체가 같은 인스턴스를 공유해야 하므로 유지형
/// [Provider]로 둔다.
final calendarEventRepositoryProvider = Provider<CalendarEventRepository>((
  ref,
) {
  return InMemoryCalendarEventRepository();
});
