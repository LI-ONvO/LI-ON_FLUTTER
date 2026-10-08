import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/core/router/app_shell.dart';
import 'package:li_on/core/widgets/layout/app_bottom_sheet.dart';
import 'package:li_on/core/widgets/layout/base_scaffold.dart';

import '../../../support/widget_test_helpers.dart';

const double _fieldHeight = 48;

/// 키보드가 올라온 작은 화면에서 공용 레이아웃이 입력창과 버튼을 가리지
/// 않는지 본다.
void main() {
  const Key lastFieldKey = Key('lastField');
  const Key submitKey = Key('submit');
  const Key bottomBarKey = Key('bottomBar');
  const Key contentKey = Key('content');

  /// 시트 안 스크롤 영역보다 훨씬 긴 입력 목록과, 아래에 고정된 버튼.
  Widget tallSheet() => AppBottomSheet(
    title: '긴 시트',
    children: [
      Flexible(
        child: SingleChildScrollView(
          child: Column(
            children: [
              for (int i = 0; i < 8; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextField(key: i == 7 ? lastFieldKey : null),
                ),
            ],
          ),
        ),
      ),
      const SizedBox(
        height: 48,
        child: ElevatedButton(
          key: submitKey,
          onPressed: null,
          child: Text('저장'),
        ),
      ),
    ],
  );

  testWidgets('바텀시트는 키보드가 올라와도 상태바 아래에서 입력창과 버튼을 키보드 위에 둔다', (tester) async {
    useSmallPhone(tester, textScale: 1.3);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showAppBottomSheet<void>(
                context: context,
                builder: (_) => tallSheet(),
              ),
              child: const Text('열기'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(lastFieldKey));
    await tester.tap(find.byKey(lastFieldKey));
    await showKeyboard(tester);

    final Rect viewport = tester.getRect(find.byType(SingleChildScrollView));
    final Rect field = tester.getRect(find.byKey(lastFieldKey));
    expect(field.top, greaterThanOrEqualTo(viewport.top));
    expect(field.bottom, lessThanOrEqualTo(viewport.bottom));
    expect(
      tester.getRect(find.byKey(submitKey)).bottom,
      lessThanOrEqualTo(keyboardTop),
    );
    // 시트는 키보드를 뺀 남은 공간을 상태바 바로 아래까지 쓴다. 키보드 높이를
    // 최대 높이 안에서 빼면 시트가 낮아져 스크롤 영역이 좁아진다.
    final double sheetTop = tester.getTopLeft(find.byType(AppBottomSheet)).dy;
    expect(sheetTop, inInclusiveRange(statusBarHeight, statusBarHeight + 16));
  });

  Widget screenWithBottomBar() => BaseScaffold(
    appBar: null,
    bottomBar: const SizedBox(key: bottomBarKey, height: 48),
    child: const Column(
      children: [
        SizedBox(height: _fieldHeight, child: TextField()),
        Expanded(child: SizedBox.expand(key: contentKey)),
      ],
    ),
  );

  /// 본문 높이: 키보드 윗면에서 상태바, 입력창, 하단 영역(48 + 위아래 12씩)을
  /// 뺀 값이다. 키보드 높이를 두 번 빼면 이보다 훨씬 작아진다.
  const double expectedContentHeight =
      keyboardTop - statusBarHeight - _fieldHeight - 72;

  testWidgets('하단 영역은 키보드가 올라오면 키보드 바로 위로 올라온다', (tester) async {
    useSmallPhone(tester);
    await tester.pumpWidget(MaterialApp(home: screenWithBottomBar()));

    await tester.tap(find.byType(TextField));
    await showKeyboard(tester);

    expect(
      tester.getRect(find.byKey(bottomBarKey)).bottom,
      lessThanOrEqualTo(keyboardTop),
    );
    expect(
      tester.getSize(find.byKey(contentKey)).height,
      closeTo(expectedContentHeight, 1),
    );
  });

  testWidgets('탭 셸 안의 화면도 키보드 높이를 한 번만 뺀다', (tester) async {
    useSmallPhone(tester);
    final GoRouter router = GoRouter(
      initialLocation: '/tab',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => AppShell(navigationShell: shell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/tab',
                  builder: (context, state) => screenWithBottomBar(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextField));
    await showKeyboard(tester);

    expect(
      tester.getRect(find.byKey(bottomBarKey)).bottom,
      lessThanOrEqualTo(keyboardTop),
    );
    expect(
      tester.getSize(find.byKey(contentKey)).height,
      closeTo(expectedContentHeight, 1),
    );
  });
}
