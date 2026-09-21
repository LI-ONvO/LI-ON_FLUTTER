import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/features/calendar/data/calendar_repository.dart';

void main() {
  test('기본 일정은 종료 시간이 시작 시간보다 늦다', () async {
    final events = await InMemoryCalendarEventRepository().fetchEvents();

    expect(events, isNotEmpty);
    expect(
      events.every((event) => event.effectiveEndAt.isAfter(event.startAt)),
      isTrue,
    );
  });
}
