import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/pages/calendar/model/calendar_event.dart';
import 'package:li_on/pages/calendar/provider/calendar_repository.dart';

export 'package:li_on/pages/calendar/model/calendar_event.dart';
export 'package:li_on/pages/calendar/provider/calendar_repository.dart'
    show dummyLinkedCertificate;

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
    required CalendarEventCategory category,
    required CalendarReminder reminder,
    String? linkedCertificate,
    String? memo,
  }) async {
    final CalendarEventRepository repository = ref.read(
      calendarEventRepositoryProvider,
    );
    await repository.addEvent(
      title: title,
      startAt: startAt,
      endAt: endAt,
      category: category,
      reminder: reminder,
      linkedCertificate: linkedCertificate,
      memo: memo,
    );
    // 저장 결과를 화면에 직접 끼워 넣지 않고 저장소에서 다시 읽어, 목록이
    // 항상 저장소와 같은 상태가 되게 한다.
    state = AsyncData(await repository.fetchEvents());
  }
}

final calendarEventsProvider =
    AsyncNotifierProvider<CalendarEvents, List<CalendarEvent>>(
      CalendarEvents.new,
    );
