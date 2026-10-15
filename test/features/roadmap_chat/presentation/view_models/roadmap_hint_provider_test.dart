import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/features/roadmap_chat/presentation/view_models/roadmap_hint_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _open({bool alwaysShow = false}) async {
  final ProviderContainer container = ProviderContainer(
    overrides: [roadmapHintAlwaysShowProvider.overrideWithValue(alwaysShow)],
  );
  addTearDown(container.dispose);
  container.listen(roadmapHintProvider, (_, _) {});
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
  return container;
}

void main() {
  test('처음 들어오면 안내를 보여주고, 닫으면 다시 열어도 보이지 않는다', () async {
    SharedPreferences.setMockInitialValues({});

    final ProviderContainer first = await _open();
    expect(first.read(roadmapHintProvider), isTrue);

    await first.read(roadmapHintProvider.notifier).dismiss();
    expect(first.read(roadmapHintProvider), isFalse);

    final ProviderContainer second = await _open();
    expect(second.read(roadmapHintProvider), isFalse);
  });

  test('디버그 스위치가 켜져 있으면 본 기록이 있어도 보여준다', () async {
    SharedPreferences.setMockInitialValues({
      'roadmap_button_hint_seen_v3': true,
    });

    final ProviderContainer container = await _open(alwaysShow: true);
    expect(container.read(roadmapHintProvider), isTrue);
  });
}
