import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/features/calendar/data/calendar_event.dart';
import 'package:li_on/features/calendar/data/calendar_repository.dart';

export 'package:li_on/features/calendar/data/calendar_event.dart';

/// 캘린더에 저장된 일정 목록. 시트에서 일정을 추가하면 [add]로 들어오고,
/// 캘린더 화면은 이 목록을 지켜보므로 추가 즉시 새 일정이 보인다.
class CalendarEvents extends AsyncNotifier<List<CalendarEvent>> {
  @override
  Future<List<CalendarEvent>> build() {
    return ref.watch(calendarEventRepositoryProvider).fetchEvents();
  }

  Future<void> add({
    required String title,
    required DateTime startAt,
    required DateTime endAt,
    required CalendarReminder reminder,
    int? roadmapStepId,
    String? description,
  }) async {
    final CalendarEventRepository repository = ref.read(
      calendarEventRepositoryProvider,
    );
    await repository.addEvent(
      title: title,
      startAt: startAt,
      endAt: endAt,
      reminder: reminder,
      roadmapStepId: roadmapStepId,
      description: description,
    );
    // 저장 결과를 화면에 직접 끼워 넣지 않고 저장소에서 다시 읽어, 목록이
    // 항상 저장소와 같은 상태가 되게 한다.
    state = AsyncData(await repository.fetchEvents());
  }

  Future<void> edit(CalendarEvent event) async {
    final CalendarEventRepository repository = ref.read(
      calendarEventRepositoryProvider,
    );
    await repository.updateEvent(event);
    state = AsyncData(await repository.fetchEvents());
  }

  Future<void> remove(int id) async {
    final CalendarEventRepository repository = ref.read(
      calendarEventRepositoryProvider,
    );
    await repository.removeEvent(id);
    state = AsyncData(await repository.fetchEvents());
  }
}

final calendarEventsProvider =
    AsyncNotifierProvider<CalendarEvents, List<CalendarEvent>>(
      CalendarEvents.new,
    );

/// 선택한 날짜에 표시할 일정. 화면이 다시 그려져도 필터·정렬을 provider
/// 캐시에 맡겨 동일한 날짜의 계산을 반복하지 않는다.
final calendarEventsForDateProvider =
    Provider.family<List<CalendarEvent>, DateTime>((ref, date) {
      final List<CalendarEvent> events =
          ref.watch(calendarEventsProvider).value ?? const [];
      final List<CalendarEvent> selected =
          events.where((event) => event.occursOn(date)).toList()
            ..sort((a, b) => a.startAt.compareTo(b.startAt));
      return selected;
    });
