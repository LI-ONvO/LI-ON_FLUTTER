import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/core/router/fading_branch_container.dart';

/// 누른 횟수를 기억하는 탭 화면. 탭을 오가도 상태가 남는지 확인한다.
class _Counter extends StatefulWidget {
  const _Counter(this.label);

  final String label;

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Center(
        child: TextButton(
          onPressed: () => setState(() => _count++),
          child: Text('${widget.label} $_count'),
        ),
      ),
    );
  }
}

void main() {
  Future<void> pumpTabs(
    WidgetTester tester,
    int index, {
    bool disableAnimations = false,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: disableAnimations),
          child: FadingBranchContainer(
            currentIndex: index,
            children: const [_Counter('탐색'), _Counter('로드맵'), _Counter('자료방')],
          ),
        ),
      ),
    );
  }

  /// [text]가 화면에 보이는 정도. 감싼 Opacity들을 곱한다.
  double visibleOpacity(WidgetTester tester, String text) {
    double opacity = 1;
    for (final FadeTransition fade in tester.widgetList(
      find.ancestor(of: find.text(text), matching: find.byType(FadeTransition)),
    )) {
      opacity *= fade.opacity.value;
    }
    return opacity;
  }

  bool isOnstage(String text) => find.text(text).evaluate().isNotEmpty;

  testWidgets('처음에는 현재 탭만 보인다', (tester) async {
    await pumpTabs(tester, 0);

    expect(find.text('탐색 0'), findsOneWidget);
    expect(find.text('로드맵 0'), findsNothing);
    expect(find.text('자료방 0'), findsNothing);
  });

  for (final (from, to, fromText, toText) in [
    (0, 1, '탐색 0', '로드맵 0'),
    (2, 0, '자료방 0', '탐색 0'),
  ]) {
    testWidgets('$fromText → $toText 탭으로 바꾸면 겹쳐서 서서히 바뀐다', (tester) async {
      await pumpTabs(tester, from);
      await pumpTabs(tester, to);
      await tester.pump(const Duration(milliseconds: 100));

      // 전환 중에는 두 화면이 함께 그려지고, 새 화면이 일부만 드러나 있다.
      expect(isOnstage(fromText), isTrue);
      expect(isOnstage(toText), isTrue);
      final double shown = to > from
          ? visibleOpacity(tester, toText)
          : 1 - visibleOpacity(tester, fromText);
      expect(shown, greaterThan(0));
      expect(shown, lessThan(1));

      // 떠나는 화면은 눌리지 않는다.
      expect(find.text(fromText).hitTestable(), findsNothing);

      await tester.pumpAndSettle();
      expect(find.text(fromText), findsNothing);
      expect(find.text(toText), findsOneWidget);
      expect(visibleOpacity(tester, toText), 1);
    });
  }

  testWidgets('탭을 오가도 각 탭의 상태가 유지된다', (tester) async {
    await pumpTabs(tester, 0);
    await tester.tap(find.text('탐색 0'));
    await tester.pump();

    await pumpTabs(tester, 1);
    await tester.pumpAndSettle();
    await pumpTabs(tester, 0);
    await tester.pumpAndSettle();

    expect(find.text('탐색 1'), findsOneWidget);
  });

  testWidgets('애니메이션 줄이기 설정이면 바로 바뀐다', (tester) async {
    await pumpTabs(tester, 0, disableAnimations: true);
    await pumpTabs(tester, 1, disableAnimations: true);

    expect(find.text('탐색 0'), findsNothing);
    expect(find.text('로드맵 0'), findsOneWidget);
    expect(visibleOpacity(tester, '로드맵 0'), 1);
  });
}
