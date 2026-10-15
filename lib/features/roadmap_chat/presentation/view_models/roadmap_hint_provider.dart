import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 안내 내용이 바뀌어 다시 보여줘야 할 때는 키의 버전을 올린다.
const String _seenKey = 'roadmap_button_hint_seen_v3';

/// 디버그 빌드에서 안내를 본 기록과 상관없이 매번 보여준다. 안내 위치와 문구를
/// 확인할 때 true로 두고, 평소에는 false로 돌려 둔다. 릴리스 빌드에는 영향이 없다.
const bool _alwaysShowInDebug = false;

/// 이 값이 true면 [RoadmapHintNotifier]가 본 기록을 무시한다. 테스트에서
/// override해 끌 수 있도록 provider로 둔다.
final roadmapHintAlwaysShowProvider = Provider<bool>(
  (ref) => kDebugMode && _alwaysShowInDebug,
);

/// 앱바의 로드맵 버튼을 알려주는 안내를 지금 보여줄지. 처음 한 번만 보여주고,
/// 닫으면 기기에 기억해 다시 띄우지 않는다. 저장소를 읽지 못하면 안내가
/// 반복되지 않게 이미 본 것으로 친다.
class RoadmapHintNotifier extends Notifier<bool> {
  @override
  bool build() {
    Future.microtask(_load);
    return false;
  }

  Future<void> _load() async {
    if (ref.read(roadmapHintAlwaysShowProvider)) {
      state = true;
      return;
    }
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (!ref.mounted) return;
      state = !(prefs.getBool(_seenKey) ?? false);
    } catch (_) {}
  }

  Future<void> dismiss() async {
    if (!state) return;
    state = false;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_seenKey, true);
    } catch (_) {}
  }
}

final roadmapHintProvider = NotifierProvider<RoadmapHintNotifier, bool>(
  RoadmapHintNotifier.new,
);
