import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/features/calendar/data/calendar_repository.dart';
import 'package:li_on/features/calendar/presentation/pages/calendar_page.dart';
import 'package:li_on/features/calendar/presentation/view_models/calendar_view_model.dart';

import '../../../../support/in_memory_calendar_repository.dart';

void main() {
  late InMemoryCalendarEventRepository repository;
  late ProviderContainer container;
  late CalendarEvent farEvent;
  late CalendarEvent otherFarEvent;

  setUp(() async {
    repository = InMemoryCalendarEventRepository();
    // 오늘이 속한 달이 아닌 먼 달에 일정을 둬서, 화면이 그 일정의 달로 옮겨
    // 가야만 보이게 한다.
    final DateTime now = DateTime.now();
    farEvent = await repository.addEvent(
      title: '두 달 뒤 시험',
      startAt: DateTime(now.year, now.month + 2, 10, 9),
      endAt: DateTime(now.year, now.month + 2, 10, 10),
      reminder: CalendarReminder.none,
    );
    otherFarEvent = await repository.addEvent(
      title: '석 달 뒤 면접',
      startAt: DateTime(now.year, now.month + 3, 20, 14),
      endAt: DateTime(now.year, now.month + 3, 20, 15),
      reminder: CalendarReminder.none,
    );
    container = ProviderContainer(
      overrides: [
        calendarEventRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
  });

  Future<void> pumpPage(WidgetTester tester, {int? focusEventId}) {
    return tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: CalendarPage(focusEventId: focusEventId)),
      ),
    );
  }

  testWidgets('알림으로 열면 그 일정이 있는 달과 날짜를 골라 보여 준다', (tester) async {
    await pumpPage(tester);
    await tester.pumpAndSettle();
    expect(find.text('두 달 뒤 시험'), findsNothing);

    await pumpPage(tester, focusEventId: farEvent.id);
    await tester.pumpAndSettle();

    expect(find.text('두 달 뒤 시험'), findsOneWidget);
  });

  testWidgets('이미 열려 있는 캘린더도 다른 알림이 오면 그 일정으로 옮겨 간다', (tester) async {
    await pumpPage(tester, focusEventId: farEvent.id);
    await tester.pumpAndSettle();
    expect(find.text('두 달 뒤 시험'), findsOneWidget);

    await pumpPage(tester, focusEventId: otherFarEvent.id);
    await tester.pumpAndSettle();

    expect(find.text('석 달 뒤 면접'), findsOneWidget);
    expect(find.text('두 달 뒤 시험'), findsNothing);
  });

  testWidgets('알림을 받은 뒤 다른 기기에서 만든 일정도 새로 받아서 찾는다', (tester) async {
    await pumpPage(tester);
    await tester.pumpAndSettle();
    final DateTime now = DateTime.now();
    final CalendarEvent created = await repository.addEvent(
      title: '다른 기기에서 만든 일정',
      startAt: DateTime(now.year, now.month + 1, 5, 9),
      endAt: DateTime(now.year, now.month + 1, 5, 10),
      reminder: CalendarReminder.none,
    );

    await pumpPage(tester, focusEventId: created.id);
    await tester.pumpAndSettle();

    expect(find.text('다른 기기에서 만든 일정'), findsOneWidget);
  });

  testWidgets('알림이 가리키는 일정이 없으면 안내만 하고 화면은 그대로 둔다', (tester) async {
    await pumpPage(tester, focusEventId: 9999);
    await tester.pumpAndSettle();

    expect(find.text('알림의 일정을 찾을 수 없어요'), findsOneWidget);
    expect(find.text('두 달 뒤 시험'), findsNothing);
  });
}
