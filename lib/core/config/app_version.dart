import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

/// 마이페이지에 보여줄 앱 버전 문구. 예: `1.0.0+3 · 패치 #2`.
///
/// Shorebird 패치 번호는 스토어 릴리스마다 #1부터 다시 시작하므로 앱 버전과
/// 함께 보여준다. 패치는 백그라운드에서 받아 다음 실행 때 적용되므로, 이미
/// 받아 둔 패치가 있으면 `(재시작 시 #3 적용)`을 덧붙인다. `flutter run`처럼
/// Shorebird로 빌드하지 않은 앱에서는 패치 정보 없이 버전만 보여준다.
final appVersionLabelProvider = FutureProvider<String>((ref) async {
  final PackageInfo info = await PackageInfo.fromPlatform();
  final String version = '${info.version}+${info.buildNumber}';

  final ShorebirdUpdater updater = ShorebirdUpdater();
  if (!updater.isAvailable) return version;

  // 패치 정보를 못 읽어도 버전은 보여줄 수 있으므로 실패는 기록만 한다.
  try {
    final Patch? current = await updater.readCurrentPatch();
    final Patch? next = await updater.readNextPatch();

    final String label = current == null
        ? version
        : '$version · 패치 #${current.number}';
    if (next != null && next.number != current?.number) {
      return '$label (재시작 시 #${next.number} 적용)';
    }
    return label;
  } on ReadPatchException catch (error) {
    debugPrint('[shorebird] 패치 정보를 읽지 못했어요: $error');
    return version;
  }
});
