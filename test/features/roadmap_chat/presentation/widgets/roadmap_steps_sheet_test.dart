import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/features/calendar/data/calendar_event.dart';
import 'package:li_on/features/calendar/data/calendar_repository.dart';
import 'package:li_on/features/roadmap/data/roadmap_detail.dart';
import 'package:li_on/features/roadmap/data/roadmap_repository.dart';
import 'package:li_on/features/roadmap/data/roadmap_summary.dart';
import 'package:li_on/features/roadmap_chat/presentation/widgets/roadmap_steps_sheet.dart';

import '../../../../support/in_memory_calendar_repository.dart';

/// 로드맵 API만 흉내 낸다. 쓰지 않는 메서드를 부르면 바로 실패한다.
class _FakeRoadmapRepository implements RoadmapRepository {
  _FakeRoadmapRepository({
    List<RoadmapStep>? existing,
    this.created = const [],
    this.failCreateTimes = 0,
  }) : _steps = existing;

  /// 세션에 이미 있는 로드맵의 스텝. null이면 로드맵이 없다.
  List<RoadmapStep>? _steps;

  /// [createRoadmap]을 부르면 서버에 생기는 스텝.
  final List<RoadmapStep> created;

  /// 처음 몇 번의 [createRoadmap] 호출을 실패시킬지.
  int failCreateTimes;

  int createCalls = 0;

  @override
  Future<List<RoadmapSummary>> fetchRoadmaps(int sessionId) async => [
    if (_steps != null)
      RoadmapSummary(id: 1, title: '로드맵', createdAt: DateTime(2026, 10, 1)),
  ];

  @override
  Future<RoadmapDetail> fetchRoadmapDetail(int roadmapId) async =>
      RoadmapDetail(id: roadmapId, title: '로드맵', steps: _steps!);

  @override
  Future<RoadmapDetail> createRoadmap({
    required int sessionId,
    String? title,
  }) async {
    createCalls++;
    if (createCalls <= failCreateTimes) throw StateError('생성 실패');
    _steps = created;
    return RoadmapDetail(id: 1, title: '로드맵', steps: created);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

RoadmapStep _step(int id, int orderNo, {DateTime? targetDate}) {
  return RoadmapStep(
    id: id,
    title: '$orderNo단계',
    description: '$orderNo단계 설명',
    orderNo: orderNo,
    targetDate: targetDate,
  );
}

void main() {
  late InMemoryCalendarEventRepository calendar;

  Future<void> pumpSheet(
    WidgetTester tester,
    _FakeRoadmapRepository roadmaps,
  ) async {
    calendar = InMemoryCalendarEventRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          roadmapRepositoryProvider.overrideWithValue(roadmaps),
          calendarEventRepositoryProvider.overrideWithValue(calendar),
        ],
        child: const MaterialApp(
          home: Scaffold(body: RoadmapStepsSheet(sessionId: 7)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('로드맵이 없으면 생성한 뒤 스텝을 orderNo 순서로 보여준다', (tester) async {
    final roadmaps = _FakeRoadmapRepository(
      created: [
        _step(2, 2, targetDate: DateTime(2026, 11, 20)),
        _step(1, 1, targetDate: DateTime(2026, 11, 1)),
      ],
    );

    await pumpSheet(tester, roadmaps);

    expect(roadmaps.createCalls, 1);
    expect(
      tester.getTopLeft(find.text('1단계')).dy,
      lessThan(tester.getTopLeft(find.text('2단계')).dy),
    );
  });

  testWidgets('이미 로드맵이 있으면 다시 생성하지 않는다', (tester) async {
    final roadmaps = _FakeRoadmapRepository(
      existing: [_step(1, 1, targetDate: DateTime(2026, 11, 1))],
    );

    await pumpSheet(tester, roadmaps);

    expect(roadmaps.createCalls, 0);
    expect(find.text('1단계'), findsOneWidget);
  });

  testWidgets('캘린더에 추가하면 목표일 오전 9시에 스텝 ID와 함께 저장된다', (tester) async {
    final roadmaps = _FakeRoadmapRepository(
      existing: [_step(5, 1, targetDate: DateTime(2026, 11, 1))],
    );
    await pumpSheet(tester, roadmaps);

    await tester.tap(find.text('캘린더에 추가'));
    await tester.pumpAndSettle();

    final List<CalendarEvent> events = await calendar.fetchEvents();
    final CalendarEvent saved = events.last;
    expect(saved.title, '1단계');
    expect(saved.description, '1단계 설명');
    expect(saved.roadmapStepId, 5);
    expect(saved.startAt, DateTime(2026, 11, 1, 9));
    expect(saved.endAt, DateTime(2026, 11, 1, 10));
    expect(find.text('추가됨'), findsOneWidget);
  });

  testWidgets('이미 캘린더에 담긴 스텝은 추가됨으로 보인다', (tester) async {
    final roadmaps = _FakeRoadmapRepository(
      existing: [_step(5, 1, targetDate: DateTime(2026, 11, 1))],
    );
    calendar = InMemoryCalendarEventRepository();
    await calendar.addEvent(
      title: '1단계',
      startAt: DateTime(2026, 11, 1, 9),
      endAt: DateTime(2026, 11, 1, 10),
      reminder: CalendarReminder.none,
      roadmapStepId: 5,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          roadmapRepositoryProvider.overrideWithValue(roadmaps),
          calendarEventRepositoryProvider.overrideWithValue(calendar),
        ],
        child: const MaterialApp(
          home: Scaffold(body: RoadmapStepsSheet(sessionId: 7)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('추가됨'), findsOneWidget);
    expect(find.text('캘린더에 추가'), findsNothing);
  });

  testWidgets('목표일이 없는 스텝은 캘린더에 추가할 수 없다', (tester) async {
    final roadmaps = _FakeRoadmapRepository(existing: [_step(1, 1)]);

    await pumpSheet(tester, roadmaps);

    expect(find.text('목표일 미정'), findsOneWidget);
    final TextButton button = tester.widget<TextButton>(
      find.widgetWithText(TextButton, '캘린더에 추가'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('생성에 실패하면 안내하고, 다시 시도하면 스텝을 보여준다', (tester) async {
    final roadmaps = _FakeRoadmapRepository(
      created: [_step(1, 1, targetDate: DateTime(2026, 11, 1))],
      failCreateTimes: 1,
    );
    await pumpSheet(tester, roadmaps);
    expect(find.text('로드맵을 만들지 못했어요'), findsOneWidget);

    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();

    expect(roadmaps.createCalls, 2);
    expect(find.text('1단계'), findsOneWidget);
  });
}
