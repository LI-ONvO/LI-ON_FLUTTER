import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/core/notification/push_notification_service.dart';

import '../../support/fake_firebase_messaging.dart';

void main() {
  late FakeFirebaseMessaging messaging;

  setUpAll(() async {
    messaging = await installFakeFirebaseMessaging();
  });

  setUp(() {
    // 이 테스트는 FCM 처리만 본다. Android 로컬 알림 플러그인은 기기에서만 등록되므로
    // 플랫폼을 iOS로 두어 건너뛴다(LocalNotificationService는 Android에서만 동작).
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    messaging
      ..authorizationStatus = AuthorizationStatus.authorized
      ..initialMessage = null;
  });

  /// [PushNotificationService.initialize]를 부르고, 그 뒤에 들어온 토큰 갱신과
  /// 알림 탭을 모아서 돌려준다.
  Future<({List<String> tokens, List<Map<String, dynamic>> taps})>
  initialize() async {
    final List<String> tokens = [];
    final List<Map<String, dynamic>> taps = [];
    await PushNotificationService.initialize(
      onTokenRefresh: tokens.add,
      onNotificationTap: taps.add,
    );
    return (tokens: tokens, taps: taps);
  }

  for (final AuthorizationStatus status in [
    AuthorizationStatus.authorized,
    // 거부한 뒤 설정 앱에서 허용해도 앱을 다시 켜지 않아도 되도록, 거부 상태에서도
    // 같은 처리가 등록돼야 한다.
    AuthorizationStatus.denied,
  ]) {
    group('알림 권한이 ${status.name}일 때', () {
      setUp(() => messaging.authorizationStatus = status);

      test('실행 중에 누른 알림의 data를 넘긴다', () async {
        final result = await initialize();

        emitNotificationOpened(
          const RemoteMessage(data: {'eventId': '5', 'alarmId': '12'}),
        );
        await Future<void>.delayed(Duration.zero);

        expect(result.taps, [
          {'eventId': '5', 'alarmId': '12'},
        ]);
      });

      test('종료된 상태에서 알림으로 켜졌다면 그 알림의 data를 넘긴다', () async {
        messaging.initialMessage = const RemoteMessage(data: {'eventId': '7'});

        final result = await initialize();

        expect(result.taps, [
          {'eventId': '7'},
        ]);
      });

      test('토큰이 갱신되면 새 토큰을 넘긴다', () async {
        final result = await initialize();

        messaging.tokenRefresh.add('new-token');
        await Future<void>.delayed(Duration.zero);

        expect(result.tokens, ['new-token']);
      });
    });
  }
}
