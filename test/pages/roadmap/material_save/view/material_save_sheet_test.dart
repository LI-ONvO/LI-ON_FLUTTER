import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/pages/data_room/provider/data_room_view_model.dart';
import 'package:li_on/pages/roadmap/material_save/view/material_save_sheet.dart';

void main() {
  Future<ProviderContainer> pumpSheet(WidgetTester tester) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: MaterialSaveSheet(certificateName: '정보처리기사')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('추천 자료를 불러오면 제목 입력창이 추천 제목으로 채워진다', (tester) async {
    await pumpSheet(tester);

    // 미리보기 카드와 제목 입력창 양쪽에 같은 제목이 보인다.
    expect(find.text('정보처리기사 필기 기출문제 모음'), findsNWidgets(2));
  });

  testWidgets('사용자가 정한 제목으로 자료방에 저장된다', (tester) async {
    final ProviderContainer container = await pumpSheet(tester);

    // 첫 번째 입력창이 제목, 두 번째가 메모다.
    await tester.enterText(find.byType(TextFormField).first, '내가 정한 제목');
    await tester.pump();

    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    final List<SavedMaterial> materials = await container.read(
      dataRoomMaterialsProvider.future,
    );
    expect(materials.map((material) => material.title), contains('내가 정한 제목'));
  });

  testWidgets('제목을 비우면 저장할 수 없다', (tester) async {
    await pumpSheet(tester);

    await tester.enterText(find.byType(TextFormField).first, '   ');
    await tester.pump();

    final ElevatedButton button = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );
    expect(button.onPressed, isNull);
  });
}
