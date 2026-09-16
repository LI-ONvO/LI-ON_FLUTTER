import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/network/api_client.dart';
import 'package:li_on/core/network/api_exception.dart';
import 'package:li_on/pages/calendar/model/calendar_event.dart';

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
    required CalendarReminder reminder,
    int? roadmapStepId,
    String? description,
  });

  /// [event]와 같은 id를 가진 일정을 통째로 덮어쓴다.
  Future<CalendarEvent> updateEvent(CalendarEvent event);

  /// [id]에 해당하는 일정을 지운다.
  Future<void> removeEvent(int id);
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

/// 일정을 들고 있는 저장소. 앱 전체가 같은 인스턴스를 공유해야 하므로 유지형
/// [Provider]로 둔다.
final calendarEventRepositoryProvider = Provider<CalendarEventRepository>((
  ref,
) {
  return HttpCalendarEventRepository(ref.watch(apiClientProvider));
});

/// 화면의 단일 선택 리마인더와 서버의 `alarms`(절대 시각 알림 목록)를
/// 서로 변환한다.
Duration? _reminderOffset(CalendarReminder reminder) => switch (reminder) {
  CalendarReminder.none => null,
  CalendarReminder.minutes5 => const Duration(minutes: 5),
  CalendarReminder.minutes10 => const Duration(minutes: 10),
  CalendarReminder.minutes30 => const Duration(minutes: 30),
  CalendarReminder.hour1 => const Duration(hours: 1),
  CalendarReminder.day1 => const Duration(days: 1),
};

List<Map<String, dynamic>> _alarmsFromReminder(
  CalendarReminder reminder,
  DateTime startAt,
) {
  final Duration? offset = _reminderOffset(reminder);
  if (offset == null) return const [];
  return [
    // 알림은 푸시로만 발송되며, 명세서 기준 요청에 `channel`을 받지 않는다.
    {'remindAt': startAt.subtract(offset).toUtc().toIso8601String()},
  ];
}

CalendarReminder _reminderFromAlarms(DateTime startAt, dynamic alarms) {
  if (alarms is! List || alarms.isEmpty) return CalendarReminder.none;
  final remindAtRaw = (alarms.first as Map<String, dynamic>)['remindAt'];
  final DateTime? remindAt = DateTime.tryParse(remindAtRaw as String? ?? '');
  if (remindAt == null) return CalendarReminder.none;
  final Duration offset = startAt.difference(remindAt);
  for (final CalendarReminder reminder in CalendarReminder.values) {
    if (_reminderOffset(reminder) == offset) return reminder;
  }
  return CalendarReminder.none;
}

/// `/api/calendar/events` CRUD를 쓰는 실제 구현체.
class HttpCalendarEventRepository implements CalendarEventRepository {
  HttpCalendarEventRepository(this.apiClient);

  final ApiClient apiClient;

  static String _dateParam(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  @override
  Future<List<CalendarEvent>> fetchEvents() {
    return guardApiCall(() async {
      // 서버가 조회 기간을 최대 366일로 제한해, 오늘 기준 앞뒤 180일
      // (총 360일)만 받아온다.
      final DateTime now = DateTime.now();
      final response = await apiClient.dio.get(
        '/api/calendar/events',
        queryParameters: {
          'from': _dateParam(now.subtract(const Duration(days: 180))),
          'to': _dateParam(now.add(const Duration(days: 180))),
        },
      );
      return (response.data as List).map((item) {
        final json = item as Map<String, dynamic>;
        final CalendarEvent event = CalendarEvent.fromJson(json);
        return CalendarEvent(
          id: event.id,
          title: event.title,
          startAt: event.startAt,
          endAt: event.endAt,
          reminder: _reminderFromAlarms(event.startAt, json['alarms']),
          roadmapStepId: event.roadmapStepId,
          description: event.description,
        );
      }).toList();
    });
  }

  @override
  Future<CalendarEvent> addEvent({
    required String title,
    required DateTime startAt,
    required DateTime endAt,
    required CalendarReminder reminder,
    int? roadmapStepId,
    String? description,
  }) {
    return guardApiCall(() async {
      final response = await apiClient.dio.post(
        '/api/calendar/events',
        data: {
          'title': title,
          'description': ?description,
          'startAt': startAt.toUtc().toIso8601String(),
          'endAt': endAt.toUtc().toIso8601String(),
          'roadmapStepId': ?roadmapStepId,
          'alarms': _alarmsFromReminder(reminder, startAt),
        },
      );
      final CalendarEvent created = CalendarEvent.fromJson(response.data);
      return CalendarEvent(
        id: created.id,
        title: created.title,
        startAt: created.startAt,
        endAt: created.endAt ?? endAt,
        reminder: reminder,
        roadmapStepId: created.roadmapStepId ?? roadmapStepId,
        description: description,
      );
    });
  }

  @override
  Future<CalendarEvent> updateEvent(CalendarEvent event) {
    return guardApiCall(() async {
      await apiClient.dio.patch(
        '/api/calendar/events/${event.id}',
        data: {
          'title': event.title,
          'startAt': event.startAt.toUtc().toIso8601String(),
          'endAt': event.endAt?.toUtc().toIso8601String(),
          'alarms': _alarmsFromReminder(event.reminder, event.startAt),
        },
      );
      return event;
    });
  }

  @override
  Future<void> removeEvent(int id) {
    return guardApiCall(() async {
      await apiClient.dio.delete('/api/calendar/events/$id');
    });
  }
}
