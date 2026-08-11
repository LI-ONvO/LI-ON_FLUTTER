import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/pages/data_room/provider/data_room_view_model.dart';
import 'package:li_on/pages/data_room/view/material_detail_page.dart';

void main() {
  /// 더미 데이터의 첫 자료(정보처리기사 · 링크)를 연다.
  Future<ProviderContainer> pumpDetail(
    WidgetTester tester, {
    String materialId = '2',
  }) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    // 상세 화면은 목록 provider가 자료를 다 읽은 뒤에야 자료를 찾을 수 있다.
    await container.read(dataRoomMaterialsProvider.future);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: MaterialDetailPage(materialId: materialId)),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('자료의 제목·카테고리·형태·저장일·메모를 보여준다', (tester) async {
    await pumpDetail(tester);

    expect(find.text('자료 상세'), findsOneWidget);
    expect(find.text('기출문제 정리 링크'), findsOneWidget);
    expect(find.text('정보처리기사'), findsOneWidget);
    expect(find.text('링크'), findsOneWidget);
    expect(find.text('2026.07.10 저장'), findsOneWidget);
    expect(find.text('exam-archive.kr/info-processing-2026'), findsOneWidget);
    expect(find.text('열기'), findsOneWidget);
  });

  testWidgets('없는 자료를 열면 안내 문구를 보여준다', (tester) async {
    await pumpDetail(tester, materialId: '없는-id');

    expect(find.text('자료를 찾을 수 없어요'), findsOneWidget);
  });

  testWidgets('⋮ 를 누르면 수정·삭제 메뉴가 열린다', (tester) async {
    await pumpDetail(tester);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('수정'), findsOneWidget);
    expect(find.text('삭제'), findsOneWidget);
  });

  testWidgets('메뉴에서 수정을 고르면 자료 수정 시트가 열린다', (tester) async {
    await pumpDetail(tester);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('수정'));
    await tester.pumpAndSettle();

    expect(find.text('자료 수정'), findsOneWidget);
    expect(find.text('수정 완료'), findsOneWidget);
  });

  testWidgets('메뉴에서 삭제를 고르면 확인 뒤에 자료가 지워진다', (tester) async {
    final ProviderContainer container = await pumpDetail(tester);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();

    expect(find.text('자료를 삭제할까요?'), findsOneWidget);
    expect(find.text('삭제된 자료는 복구할 수 없어요.'), findsOneWidget);

    // 다이얼로그의 '삭제' 버튼. 메뉴는 이미 닫혀 하나만 남는다.
    await tester.tap(find.widgetWithText(ElevatedButton, '삭제'));
    await tester.pumpAndSettle();

    final List<SavedMaterial> materials = await container.read(
      dataRoomMaterialsProvider.future,
    );
    expect(materials.map((material) => material.id), isNot(contains('2')));
  });

  testWidgets('삭제를 취소하면 자료가 그대로 남는다', (tester) async {
    final ProviderContainer container = await pumpDetail(tester);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, '취소'));
    await tester.pumpAndSettle();

    final List<SavedMaterial> materials = await container.read(
      dataRoomMaterialsProvider.future,
    );
    expect(materials.map((material) => material.id), contains('2'));
  });
}
