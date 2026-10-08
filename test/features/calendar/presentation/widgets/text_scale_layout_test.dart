import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/features/calendar/data/calendar_event.dart';
import 'package:li_on/features/calendar/presentation/widgets/calendar_event_tile.dart';
import 'package:li_on/features/calendar/presentation/widgets/schedule_picker_field.dart';

/// 앱이 걸어 둔 글자 배율 상한(1.3)을 훌쩍 넘는 값. 위젯 자체가 글자 크기에
/// 유연하게 늘어나는지 확인하려고 일부러 크게 잡는다.
const double _hugeTextScale = 3.0;

Future<void> _pumpScaled(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      builder: (context, home) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: const TextScaler.linear(_hugeTextScale)),
        child: home!,
      ),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('일정 타일은 글자가 커지면 높이 56을 넘어 늘어나고 넘치지 않는다', (tester) async {
    await _pumpScaled(
      tester,
      CalendarEventTile(
        event: CalendarEvent(
          id: 1,
          title: '정보처리기사 필기 시험',
          startAt: DateTime(2026, 10, 8, 15),
          endAt: DateTime(2026, 10, 8, 16),
        ),
        onTap: () {},
        onEdit: () {},
        onDelete: () {},
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(CalendarEventTile)).height,
      greaterThan(56),
    );
  });

  testWidgets('날짜·시간 선택 필드 두 개가 나란히 있어도 글자가 커지면 줄바꿈될 뿐 넘치지 않는다', (
    tester,
  ) async {
    await _pumpScaled(
      tester,
      Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: SchedulePickerField(
                icon: Icons.schedule,
                label: '오후 12:00',
                onTap: () {},
              ),
            ),
            Expanded(
              child: SchedulePickerField(
                icon: Icons.schedule,
                label: '오후 12:30',
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
