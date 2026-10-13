import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 일정 알림이 쓰는 Android 채널 id. AndroidManifest.xml의
/// `default_notification_channel_id`와 같아야, 앱이 백그라운드일 때 시스템이
/// 띄우는 FCM 알림도 이 채널을 쓴다.
const String scheduleAlarmChannelId = 'schedule_alarm';

const AndroidNotificationChannel _scheduleAlarmChannel =
    AndroidNotificationChannel(
      scheduleAlarmChannelId,
      '일정 알림',
      description: '일정 시작 전에 보내는 알림',
      importance: Importance.high,
    );

const String _statusBarIcon = '@drawable/ic_stat_notification';

/// Android는 앱이 열려 있을 때 FCM 알림을 시스템이 띄워 주지 않으므로, 이때 받은
/// 알림을 직접 띄운다. iOS는 `setForegroundNotificationPresentationOptions`로
/// 시스템이 띄우므로 아무것도 하지 않는다.
class LocalNotificationService {
  LocalNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

  /// 알림 채널을 만들고, 직접 띄운 알림을 눌렀을 때 그 알림의 `data`를
  /// [onTap]으로 넘기도록 등록한다. 알림 때문에 앱이 켜졌다면 그 알림도 넘긴다.
  static Future<void> initialize({
    required void Function(Map<String, dynamic> data) onTap,
  }) async {
    if (!_isAndroid) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(_statusBarIcon),
      ),
      onDidReceiveNotificationResponse: (response) =>
          _handleTap(response.payload, onTap),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_scheduleAlarmChannel);

    final NotificationAppLaunchDetails? launch = await _plugin
        .getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp == true) {
      _handleTap(launch?.notificationResponse?.payload, onTap);
    }
  }

  /// 앱이 열려 있을 때 받은 [message]를 Android 알림으로 띄운다. 알림 내용이
  /// 없는 데이터 메시지는 띄우지 않는다. 표시에 실패해도 메시지 수신을 막지
  /// 않도록 오류는 로그로만 남긴다.
  static Future<void> showForeground(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;
    if (!_isAndroid || notification == null) return;
    try {
      await _plugin.show(
        // 같은 알람이 다시 오면 쌓지 않고 기존 알림을 갈아 끼운다(서버의 collapse).
        id:
            int.tryParse('${message.data['alarmId'] ?? ''}') ??
            message.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _scheduleAlarmChannel.id,
            _scheduleAlarmChannel.name,
            channelDescription: _scheduleAlarmChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: _statusBarIcon,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    } catch (error) {
      debugPrint('[FCM] 포그라운드 알림을 띄우지 못했어요: $error');
    }
  }

  static void _handleTap(
    String? payload,
    void Function(Map<String, dynamic> data) onTap,
  ) {
    if (payload == null) return;
    try {
      final Object? data = jsonDecode(payload);
      if (data is Map<String, dynamic>) onTap(data);
    } on FormatException catch (error) {
      debugPrint('[FCM] 알림 payload를 읽지 못했어요: $error');
    }
  }
}
