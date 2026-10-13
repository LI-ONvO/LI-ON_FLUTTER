import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/features/certificate_search/data/certificate_detail.dart';
import 'package:li_on/features/certificate_search/presentation/widgets/exam_schedule_card.dart';

Future<void> _pump(WidgetTester tester, ExamSchedule schedule) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: ExamScheduleCard(schedule: schedule)),
    ),
  );
}

void main() {
  testWidgets('필기 일정이 없으면 실기 행만 그린다', (tester) async {
    await _pump(
      tester,
      ExamSchedule(
        implYy: 2026,
        implSeq: 1,
        pracRegStartDt: DateTime(2026, 5, 1),
        pracRegEndDt: DateTime(2026, 5, 5),
        pracPassDt: DateTime(2026, 7, 1),
      ),
    );

    expect(find.text('2026년 1회'), findsOneWidget);
    expect(find.text('실기 접수'), findsOneWidget);
    expect(find.text('2026.05.01 ~ 2026.05.05'), findsOneWidget);
    expect(find.text('실기 합격 발표'), findsOneWidget);
    expect(find.text('2026.07.01'), findsOneWidget);
    expect(find.text('실기 시험'), findsNothing);
    expect(find.textContaining('필기'), findsNothing);
  });

  testWidgets('시작일만 있으면 그 날짜만 보여준다', (tester) async {
    await _pump(
      tester,
      ExamSchedule(
        implYy: 2026,
        implSeq: 2,
        docExamStartDt: DateTime(2026, 8, 16),
      ),
    );

    expect(find.text('필기 시험'), findsOneWidget);
    expect(find.text('2026.08.16'), findsOneWidget);
    expect(find.textContaining('~'), findsNothing);
  });

  testWidgets('일정이 전부 없어도 오류 없이 제목만 그린다', (tester) async {
    await _pump(tester, const ExamSchedule(implYy: 2026, implSeq: 3));

    expect(tester.takeException(), isNull);
    expect(find.text('2026년 3회'), findsOneWidget);
    expect(find.textContaining('필기'), findsNothing);
    expect(find.textContaining('실기'), findsNothing);
  });
}
