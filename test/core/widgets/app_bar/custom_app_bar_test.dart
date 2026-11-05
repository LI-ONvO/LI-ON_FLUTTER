import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/core/widgets/app_bar/custom_app_bar.dart';

void main() {
  Future<void> pumpAppBar(
    WidgetTester tester, {
    required String title,
    Widget? titleTrailing,
    List<Widget> actions = const [],
  }) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: CustomAppBar(
            title: title,
            titleTrailing: titleTrailing,
            showBackButton: false,
            actions: actions,
          ),
        ),
      ),
    );
  }

  const List<Widget> fourActions = [
    Icon(Icons.add_comment_outlined, size: 20),
    SizedBox(width: 16),
    Icon(Icons.route_outlined, size: 20),
    SizedBox(width: 16),
    Icon(Icons.auto_awesome_outlined, size: 20),
    SizedBox(width: 16),
    Icon(Icons.more_horiz, size: 20),
  ];

  double firstActionLeft(WidgetTester tester) =>
      tester.getTopLeft(find.byIcon(Icons.add_comment_outlined)).dx;

  testWidgets('액션이 많으면 제목이 액션과 겹치지 않고 온전히 보인다', (tester) async {
    await pumpAppBar(tester, title: '프로그래밍기능사 로드맵', actions: fourActions);

    final Finder title = find.text('프로그래밍기능사 로드맵');
    expect(tester.getTopRight(title).dx, lessThan(firstActionLeft(tester)));
    expect(
      tester
          .renderObject<RenderParagraph>(
            find.descendant(of: title, matching: find.byType(RichText)),
          )
          .didExceedMaxLines,
      isFalse,
    );
  });

  testWidgets('제목이 아주 길면 말줄임되고 액션과 겹치지 않는다', (tester) async {
    final String longTitle = '정보처리산업기사 ' * 6;
    await pumpAppBar(tester, title: longTitle, actions: fourActions);

    expect(
      tester.getTopRight(find.text(longTitle)).dx,
      lessThan(firstActionLeft(tester)),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('제목 옆 위젯도 액션과 겹치지 않는다', (tester) async {
    await pumpAppBar(
      tester,
      title: '프로그래밍기능사 로드맵',
      titleTrailing: const Icon(Icons.add, size: 20),
      actions: fourActions,
    );

    expect(
      tester.getTopRight(find.byIcon(Icons.add)).dx,
      lessThan(firstActionLeft(tester)),
    );
  });

  testWidgets('제목이 짧으면 화면 가운데에 온다', (tester) async {
    await pumpAppBar(
      tester,
      title: '로드맵',
      actions: const [Icon(Icons.more_horiz, size: 20)],
    );

    expect(tester.getCenter(find.text('로드맵')).dx, 201);
  });
}
