import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/network/api_client.dart';
import 'package:li_on/core/network/api_exception.dart';
import 'package:li_on/features/calendar/data/calendar_event.dart';

/// 캘린더 일정을 읽고 쓰는 방법을 추상화한다.
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
