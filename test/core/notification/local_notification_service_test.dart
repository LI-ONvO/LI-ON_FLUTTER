import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/core/notification/local_notification_service.dart';

const MethodChannel _pluginChannel = MethodChannel(
  'dexterous.com/flutter/local_notifications',
);

const RemoteMessage _alarmMessage = RemoteMessage(
  notification: RemoteNotification(title: '정보처리기사 필기', body: '곧 시작해요'),
  data: {'alarmId': '12', 'eventId': '5'},
);

void main() {
  late List<MethodCall> calls;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    // 기기에서는 플러그인이 스스로 등록하지만 테스트에서는 직접 등록한다.
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    calls = [];
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pluginChannel, null);
  });

  void answerWith(Future<Object?> Function(MethodCall call) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pluginChannel, (call) {
          calls.add(call);
          return handler(call);
        });
  }

  test('같은 알람은 알람 id로 한 알림에 모으고, data를 payload로 실어 보낸다', () async {
    answerWith((call) async => null);

    await LocalNotificationService.showForeground(_alarmMessage);

    final MethodCall show = calls.singleWhere((call) => call.method == 'show');
    final Map<Object?, Object?> arguments = show.arguments as Map;
    expect(arguments['id'], 12);
    expect(arguments['title'], '정보처리기사 필기');
    expect(jsonDecode(arguments['payload']! as String), {
      'alarmId': '12',
      'eventId': '5',
    });
    final Map<Object?, Object?> android =
        arguments['platformSpecifics']! as Map;
    expect(android['channelId'], scheduleAlarmChannelId);
  });

  test('알림을 띄우다 실패해도 예외를 밖으로 던지지 않는다', () async {
    answerWith((call) async => throw PlatformException(code: 'invalid_icon'));

    await expectLater(
      LocalNotificationService.showForeground(_alarmMessage),
      completes,
    );
    expect(calls.where((call) => call.method == 'show'), hasLength(1));
  });

  test('알림 내용이 없는 데이터 메시지는 띄우지 않는다', () async {
    answerWith((call) async => null);

    await LocalNotificationService.showForeground(
      const RemoteMessage(data: {'eventId': '5'}),
    );

    expect(calls, isEmpty);
  });
}
