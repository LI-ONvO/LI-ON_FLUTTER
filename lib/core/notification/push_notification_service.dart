import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// 앱이 백그라운드/종료 상태일 때 수신한 FCM 메시지를 처리한다.
///
/// `main()`에서 등록되기 전에 플러그인이 메시지를 넘길 수 있으므로
/// 최상위(top-level) 함수여야 한다.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] background message: ${message.messageId}');
}

/// Firebase Cloud Messaging 초기화와 토큰/메시지 수신을 담당한다.
class PushNotificationService {
  PushNotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// `Firebase.initializeApp()` 이후 한 번 호출한다.
  ///
  /// [onTokenRefresh]는 FCM 토큰이 새로 발급될 때마다 불린다. 앱은 이
  /// 시점과 로그인 직후에 서버로 토큰을 등록해야 한다.
  static Future<void> initialize({
    required void Function(String token) onTokenRefresh,
  }) async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('[FCM] user denied notification permission');
      return;
    }

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _messaging.onTokenRefresh.listen(onTokenRefresh);

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('[FCM] foreground message: ${message.messageId}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('[FCM] opened from notification: ${message.messageId}');
    });
  }

  /// 현재 기기의 FCM 토큰. 로그인·로그아웃 시 서버에 등록/해제할 때 쓴다.
  static Future<String?> getToken() => _messaging.getToken();
}
