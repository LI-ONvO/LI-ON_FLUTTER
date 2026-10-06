import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/features/calendar/data/calendar_repository.dart';
import 'package:li_on/features/calendar/presentation/pages/schedule_form_sheet.dart';
import 'package:li_on/features/calendar/presentation/view_models/calendar_view_model.dart';
import 'package:li_on/features/calendar/presentation/widgets/schedule_picker_field.dart';

import '../../../../support/in_memory_calendar_repository.dart';

void main() {
  testWidgets('일정 폼에서 날짜·시간 선택기를 열고 일정을 저장한다', (tester) async {
    final repository = InMemoryCalendarEventRepository();
    final container = ProviderContainer(
      overrides: [
        calendarEventRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: ScheduleFormSheet(initialDate: DateTime(2026, 10, 6)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SchedulePickerField).first);
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    final dateTheme = Theme.of(tester.element(find.byType(DatePickerDialog)));
    expect(dateTheme.colorScheme.primary, AppColors.primary);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SchedulePickerField).at(2));
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '새 일정');
    await tester.pump();
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    final events = await container.read(calendarEventsProvider.future);
    expect(events.any((event) => event.title == '새 일정'), isTrue);
  });
}
