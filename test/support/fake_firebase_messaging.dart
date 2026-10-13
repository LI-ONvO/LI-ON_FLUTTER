import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// 실제 FCM 없이 [FirebaseMessaging]을 쓰는 코드를 테스트하도록, 플랫폼 계층을
/// 갈아 끼우는 가짜. 필드를 바꿔 권한·토큰·종료 상태 알림을 정한다.
class FakeFirebaseMessaging extends FirebaseMessagingPlatform
    with MockPlatformInterfaceMixin {
  AuthorizationStatus authorizationStatus = AuthorizationStatus.authorized;
  String? token = 'fcm-token';

  /// 종료된 상태에서 알림을 눌러 앱이 켜졌을 때 `getInitialMessage`가 주는 값.
  RemoteMessage? initialMessage;

  final StreamController<String> tokenRefresh =
      StreamController<String>.broadcast();

  @override
  FirebaseMessagingPlatform delegateFor({required FirebaseApp app}) => this;

  @override
  FirebaseMessagingPlatform setInitialValues({bool? isAutoInitEnabled}) => this;

  @override
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
    bool providesAppNotificationSettings = false,
  }) async => NotificationSettings(
    alert: AppleNotificationSetting.enabled,
    announcement: AppleNotificationSetting.notSupported,
    authorizationStatus: authorizationStatus,
    badge: AppleNotificationSetting.enabled,
    carPlay: AppleNotificationSetting.notSupported,
    lockScreen: AppleNotificationSetting.enabled,
    notificationCenter: AppleNotificationSetting.enabled,
    showPreviews: AppleShowPreviewSetting.always,
    timeSensitive: AppleNotificationSetting.notSupported,
    criticalAlert: AppleNotificationSetting.notSupported,
    sound: AppleNotificationSetting.enabled,
    providesAppNotificationSettings: AppleNotificationSetting.notSupported,
  );

  @override
  void registerBackgroundMessageHandler(BackgroundMessageHandler handler) {}

  @override
  Future<void> setForegroundNotificationPresentationOptions({
    bool alert = false,
    bool badge = false,
    bool sound = false,
  }) async {}

  @override
  Future<String?> getToken({
    String? serviceWorkerScriptPath,
    String? vapidKey,
  }) async => token;

  @override
  Stream<String> get onTokenRefresh => tokenRefresh.stream;

  @override
  Future<RemoteMessage?> getInitialMessage() async => initialMessage;
}

/// Firebase 초기화를 가짜로 대신하고 [FakeFirebaseMessaging]을 설치한다.
/// 테스트 파일마다 `setUpAll`에서 한 번 부른다.
Future<FakeFirebaseMessaging> installFakeFirebaseMessaging() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  await Firebase.initializeApp();
  final FakeFirebaseMessaging fake = FakeFirebaseMessaging();
  FirebaseMessagingPlatform.instance = fake;
  return fake;
}

/// 앱이 열려 있는 동안 알림을 눌렀을 때와 같은 이벤트를 흘려 보낸다.
void emitNotificationOpened(RemoteMessage message) {
  FirebaseMessagingPlatform.onMessageOpenedApp.add(message);
}

/// 앱이 열려 있는 동안 알림이 도착했을 때와 같은 이벤트를 흘려 보낸다.
void emitForegroundMessage(RemoteMessage message) {
  FirebaseMessagingPlatform.onMessage.add(message);
}
