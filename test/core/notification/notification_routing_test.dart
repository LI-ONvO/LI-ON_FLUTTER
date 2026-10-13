import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/core/auth/auth_user.dart';
import 'package:li_on/core/network/token_storage.dart';
import 'package:li_on/core/notification/device_token_repository.dart';
import 'package:li_on/core/notification/notification_navigation.dart';
import 'package:li_on/features/calendar/data/calendar_repository.dart';
import 'package:li_on/features/calendar/presentation/pages/calendar_page.dart';
import 'package:li_on/features/calendar/presentation/view_models/calendar_view_model.dart';
import 'package:li_on/main.dart';

import '../../support/fake_firebase_messaging.dart';
import '../../support/in_memory_calendar_repository.dart';

/// 스플래시가 로고를 보여 주는 시간(2초)보다 약간 긴 시간.
const Duration _pastSplash = Duration(seconds: 3);

void main() {
  late ProviderContainer container;
  late CalendarEvent firstEvent;
  late CalendarEvent secondEvent;
  late _RecordingDeviceTokenRepository deviceTokens;

  setUpAll(installFakeFirebaseMessaging);

  Future<void> setUpApp({required bool signedIn}) async {
    final InMemoryCalendarEventRepository repository =
        InMemoryCalendarEventRepository();
    final DateTime now = DateTime.now();
    firstEvent = await repository.addEvent(
      title: '두 달 뒤 시험',
      startAt: DateTime(now.year, now.month + 2, 10, 9),
      endAt: DateTime(now.year, now.month + 2, 10, 10),
      reminder: CalendarReminder.none,
    );
    secondEvent = await repository.addEvent(
      title: '석 달 뒤 면접',
      startAt: DateTime(now.year, now.month + 3, 20, 14),
      endAt: DateTime(now.year, now.month + 3, 20, 15),
      reminder: CalendarReminder.none,
    );
    deviceTokens = _RecordingDeviceTokenRepository();
    container = ProviderContainer(
      overrides: [
        deviceTokenRepositoryProvider.overrideWithValue(deviceTokens),
        calendarEventRepositoryProvider.overrideWithValue(repository),
        tokenStorageProvider.overrideWithValue(
          _FakeTokenStorage(signedIn: signedIn),
        ),
      ],
    );
    addTearDown(container.dispose);
  }

  Future<void> pumpApp(WidgetTester tester) => tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MyApp()),
  );

  void sendNotificationTap(CalendarEvent event) => container
      .read(pendingNotificationRouteProvider.notifier)
      .set('/calendar?eventId=${event.id}');

  testWidgets('종료된 상태에서 알림으로 켜지면 스플래시 뒤 그 일정으로 바로 간다', (tester) async {
    await setUpApp(signedIn: true);
    sendNotificationTap(firstEvent);

    await pumpApp(tester);
    await tester.pump(_pastSplash);
    await tester.pumpAndSettle();

    expect(find.byType(CalendarPage), findsOneWidget);
    expect(find.text('두 달 뒤 시험'), findsOneWidget);
    expect(container.read(pendingNotificationRouteProvider), isNull);
  });

  testWidgets('스플래시 중에 알림을 눌러도 스플래시가 끝난 뒤 그 일정으로 간다', (tester) async {
    await setUpApp(signedIn: true);
    await pumpApp(tester);
    await tester.pump(const Duration(seconds: 1));

    sendNotificationTap(firstEvent);
    await tester.pump();
    expect(find.byType(CalendarPage), findsNothing);

    await tester.pump(_pastSplash);
    await tester.pumpAndSettle();

    expect(find.text('두 달 뒤 시험'), findsOneWidget);
  });

  testWidgets('앱이 떠 있을 때 알림을 누르면 바로 그 일정으로 이동한다', (tester) async {
    await setUpApp(signedIn: true);
    sendNotificationTap(firstEvent);
    await pumpApp(tester);
    await tester.pump(_pastSplash);
    await tester.pumpAndSettle();
    expect(find.text('두 달 뒤 시험'), findsOneWidget);

    sendNotificationTap(secondEvent);
    await tester.pumpAndSettle();

    expect(find.text('석 달 뒤 면접'), findsOneWidget);
    expect(find.text('두 달 뒤 시험'), findsNothing);
    expect(container.read(pendingNotificationRouteProvider), isNull);
  });

  testWidgets('로그인하지 않았다면 알림 경로는 버리고 로그인 화면으로 간다', (tester) async {
    await setUpApp(signedIn: false);
    sendNotificationTap(firstEvent);

    await pumpApp(tester);
    await tester.pump(_pastSplash);
    await tester.pumpAndSettle();

    expect(find.byType(CalendarPage), findsNothing);
    expect(container.read(pendingNotificationRouteProvider), isNull);
  });

  testWidgets('같은 알림을 다시 눌러도, 다른 달로 옮겨 간 뒤라면 그 일정으로 돌아온다', (tester) async {
    await setUpApp(signedIn: true);
    sendNotificationTap(firstEvent);
    await pumpApp(tester);
    await tester.pump(_pastSplash);
    await tester.pumpAndSettle();
    expect(find.text('두 달 뒤 시험'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left).first);
    await tester.pumpAndSettle();
    expect(find.text('두 달 뒤 시험'), findsNothing);

    sendNotificationTap(firstEvent);
    await tester.pumpAndSettle();

    expect(find.text('두 달 뒤 시험'), findsOneWidget);
  });

  testWidgets('로그인된 채로 앱을 켜면 세션을 복원한 뒤 현재 FCM 토큰을 서버에 등록한다', (tester) async {
    await setUpApp(signedIn: true);

    await pumpApp(tester);
    await tester.pump(_pastSplash);
    await tester.pumpAndSettle();

    expect(deviceTokens.registered, ['fcm-token']);
  });

  testWidgets('로그인하지 않은 채로 앱을 켜면 토큰을 등록하지 않는다', (tester) async {
    await setUpApp(signedIn: false);

    await pumpApp(tester);
    await tester.pump(_pastSplash);
    await tester.pumpAndSettle();

    expect(deviceTokens.registered, isEmpty);
  });
}

class _RecordingDeviceTokenRepository implements DeviceTokenRepository {
  final List<String> registered = [];

  @override
  Future<void> register(String token) async => registered.add(token);

  @override
  Future<void> unregister(String token) async {}
}

class _FakeTokenStorage extends TokenStorage {
  _FakeTokenStorage({required this.signedIn})
    : super(const FlutterSecureStorage());

  final bool signedIn;

  @override
  Future<String?> readAccessToken() async => signedIn ? 'access-token' : null;

  @override
  Future<AuthUser?> readUser() async => signedIn
      ? const AuthUser(userId: 1, email: 'user@example.com', nickname: '닉네임')
      : null;
}
