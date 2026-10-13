import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/core/notification/notification_navigation.dart';

void main() {
  group('notificationRouteFromData', () {
    test('eventId가 있으면 그 일정을 보여 주는 캘린더 경로를 돌려준다', () {
      expect(
        notificationRouteFromData({'alarmId': '12', 'eventId': '5'}),
        '/calendar?eventId=5',
      );
    });

    test('eventId가 숫자가 아니거나 없으면 이동하지 않는다', () {
      expect(notificationRouteFromData({'eventId': 'abc'}), isNull);
      expect(notificationRouteFromData({'alarmId': '12'}), isNull);
      expect(notificationRouteFromData({}), isNull);
    });
  });

  group('PendingNotificationRoute', () {
    late ProviderContainer container;
    late PendingNotificationRoute pending;

    setUp(() {
      container = ProviderContainer();
      addTearDown(container.dispose);
      pending = container.read(pendingNotificationRouteProvider.notifier);
    });

    test('꺼내면 비워져서 두 번 이동하지 않는다', () {
      expect(pending.take(), isNull);

      pending.set('/calendar?eventId=5');
      expect(container.read(pendingNotificationRouteProvider), isNotNull);
      expect(pending.take(), '/calendar?eventId=5&tap=1');
      expect(pending.take(), isNull);
    });

    test('같은 경로도 누를 때마다 다른 값이 붙어 라우터가 새 이동으로 본다', () {
      pending.set('/calendar?eventId=5');
      final String? first = pending.take();
      pending.set('/calendar?eventId=5');
      final String? second = pending.take();

      expect(first, '/calendar?eventId=5&tap=1');
      expect(second, '/calendar?eventId=5&tap=2');
    });
  });
}
