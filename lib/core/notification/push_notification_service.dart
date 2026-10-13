import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:li_on/core/notification/local_notification_service.dart';

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
  ///
  /// [onNotificationTap]은 사용자가 알림을 눌렀을 때 그 알림의 `data`와 함께
  /// 불린다. 앱이 백그라운드이거나 종료된 상태에서 알림으로 켜진 경우도
  /// 포함한다.
  static Future<void> initialize({
    required void Function(String token) onTokenRefresh,
    required void Function(Map<String, dynamic> data) onNotificationTap,
  }) async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 권한을 묻기 전에 채널을 만들어 둬야 첫 알림부터 이 채널을 쓴다.
    await LocalNotificationService.initialize(onTap: onNotificationTap);

    final NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 거부했더라도 여기서 끝내지 않는다. 나중에 설정 앱에서 알림을 허용하면
    // 앱을 다시 켜지 않아도 알림 탭 처리와 토큰 갱신이 동작해야 하기 때문이다.
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('[FCM] user denied notification permission');
    }

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _messaging.onTokenRefresh.listen(onTokenRefresh);
    if (kDebugMode) _logToken();

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('[FCM] foreground message: ${message.messageId}');
      LocalNotificationService.showForeground(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('[FCM] opened from notification: ${message.messageId}');
      onNotificationTap(message.data);
    });

    // 앱이 종료된 상태에서 알림을 눌러 켜진 경우, 그 알림은 이벤트로 오지 않고
    // 여기서만 얻을 수 있다.
    final RemoteMessage? launchMessage = await _messaging.getInitialMessage();
    if (launchMessage != null) onNotificationTap(launchMessage.data);
  }

  /// Firebase 콘솔의 테스트 메시지에 붙여 넣을 수 있게 디버그 빌드에서만
  /// 토큰을 로그로 찍는다. 토큰을 못 받는 환경(iOS 시뮬레이터 등)이어도
  /// 앱 시작을 막지 않도록 await하지 않고 오류는 로그로만 남긴다.
  static Future<void> _logToken() async {
    try {
      debugPrint('[FCM] token: ${await _messaging.getToken()}');
    } catch (error) {
      debugPrint('[FCM] token unavailable: $error');
    }
  }

  /// 현재 기기의 FCM 토큰. 로그인·로그아웃 시 서버에 등록/해제할 때 쓴다.
  static Future<String?> getToken() => _messaging.getToken();
}
