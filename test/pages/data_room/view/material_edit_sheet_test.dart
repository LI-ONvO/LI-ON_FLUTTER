import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/pages/data_room/provider/data_room_view_model.dart';
import 'package:li_on/pages/data_room/view/material_edit_sheet.dart';

void main() {
  Future<ProviderContainer> pumpSheet(WidgetTester tester) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    final List<SavedMaterial> materials = await container.read(
      dataRoomMaterialsProvider.future,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: MaterialEditSheet(
              material: materials.firstWhere((material) => material.id == '1'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('저장된 제목·메모·카테고리가 채워진 채로 열린다', (tester) async {
    await pumpSheet(tester);

    expect(find.text('자료 수정'), findsOneWidget);
    expect(find.text('필기 핵심요약 PDF'), findsOneWidget);
    // 카테고리 선택지는 저장된 카테고리에 '기타'를 더해 만든다.
    expect(find.text('정보처리기사'), findsOneWidget);
    expect(find.text('빅데이터분석기사'), findsOneWidget);
    expect(find.text('기타'), findsOneWidget);
  });

  testWidgets('제목·카테고리·메모를 고치면 그대로 반영된다', (tester) async {
    final ProviderContainer container = await pumpSheet(tester);

    // 첫 번째 입력창이 제목, 두 번째가 메모다.
    await tester.enterText(find.byType(TextFormField).first, '고친 제목');
    await tester.enterText(find.byType(TextFormField).last, '고친 메모');
    await tester.tap(find.text('기타'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('수정 완료'));
    await tester.pumpAndSettle();

    final SavedMaterial updated = (await container.read(
      dataRoomMaterialsProvider.future,
    )).firstWhere((material) => material.id == '1');
    expect(updated.title, '고친 제목');
    expect(updated.memo, '고친 메모');
    expect(updated.category, '기타');
    // 수정 대상이 아닌 항목은 그대로 남는다.
    expect(updated.source, '정보처리기사 로드맵 채팅');
  });

  testWidgets('제목을 비우면 수정할 수 없다', (tester) async {
    await pumpSheet(tester);

    await tester.enterText(find.byType(TextFormField).first, '   ');
    await tester.pump();

    final ElevatedButton button = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );
    expect(button.onPressed, isNull);
  });
}
