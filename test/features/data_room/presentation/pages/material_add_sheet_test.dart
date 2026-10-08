import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/features/data_room/data/data_room_repository.dart';
import 'package:li_on/features/data_room/presentation/view_models/data_room_view_model.dart';
import 'package:li_on/features/data_room/presentation/pages/material_add_sheet.dart';
import '../../../../support/in_memory_data_room_repository.dart';

void main() {
  Future<ProviderContainer> pumpSheet(WidgetTester tester) async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        // 실제 저장소는 서버 API를 쓰므로, 테스트는 메모리 저장소로 바꾼다.
        dataRoomRepositoryProvider.overrideWithValue(
          InMemoryDataRoomRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(dataRoomMaterialsProvider.future);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: MaterialAddSheet())),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  bool isSubmitEnabled(WidgetTester tester) =>
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed !=
      null;

  testWidgets('처음에는 추가 버튼이 비활성화돼 있다', (tester) async {
    await pumpSheet(tester);

    expect(find.text('자료 추가'), findsOneWidget);
    expect(isSubmitEnabled(tester), isFalse);
  });

  testWidgets('제목만 있거나 링크만 있으면 추가할 수 없다', (tester) async {
    await pumpSheet(tester);

    // 입력창은 위에서부터 제목, 링크, 메모 순서다.
    await tester.enterText(find.byType(TextFormField).at(0), '새 자료');
    await tester.pump();
    expect(isSubmitEnabled(tester), isFalse);

    await tester.enterText(find.byType(TextFormField).at(0), '');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'https://example.com',
    );
    await tester.pump();
    expect(isSubmitEnabled(tester), isFalse);
  });

  testWidgets('제목과 링크를 입력하면 자료방에 새 자료가 추가된다', (tester) async {
    final ProviderContainer container = await pumpSheet(tester);
    final int before = (await container.read(
      dataRoomMaterialsProvider.future,
    )).length;

    await tester.enterText(find.byType(TextFormField).at(0), '새 자료');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'https://example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), '새 메모');
    await tester.pump();
    expect(isSubmitEnabled(tester), isTrue);

    await tester.tap(find.text('추가 완료'));
    await tester.pumpAndSettle();

    final List<SavedMaterial> materials = await container.read(
      dataRoomMaterialsProvider.future,
    );
    expect(materials.length, before + 1);
    final SavedMaterial added = materials.firstWhere(
      (material) => material.title == '새 자료',
    );
    expect(added.url, 'https://example.com');
    expect(added.memo, '새 메모');
  });
}
