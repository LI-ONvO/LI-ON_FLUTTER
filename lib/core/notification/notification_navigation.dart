import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 푸시 알림의 `data`를 눌렀을 때 이동할 앱 경로로 바꾼다. 서버가 보내는
/// `eventId`(일정 id, 문자열)가 있으면 그 일정을 보여 주는 캘린더 경로를
/// 돌려주고, 이동할 곳을 알 수 없으면 null이다.
String? notificationRouteFromData(Map<String, dynamic> data) {
  final int? eventId = int.tryParse('${data['eventId'] ?? ''}');
  return eventId == null ? null : '/calendar?eventId=$eventId';
}

/// 알림을 눌러 열어야 하지만 아직 이동하지 못한 경로. 앱이 종료된 상태에서
/// 알림으로 켜지면 세션 복원이 끝나기 전이라 바로 이동할 수 없으므로, 스플래시가
/// 이 값을 꺼내 간다. 앱이 떠 있을 때는 값이 들어오는 즉시 `MyApp`이 이동한다.
class PendingNotificationRoute extends Notifier<String?> {
  int _tapCount = 0;

  @override
  String? build() => null;

  /// 같은 알림을 다시 눌러도 이동하도록 탭마다 달라지는 `tap` 값을 붙인다.
  /// 경로가 이전과 같으면 라우터가 이동 자체를 무시해, 사용자가 다른 달로
  /// 옮겨 간 뒤에는 일정으로 돌아오지 못한다.
  void set(String route) {
    final Uri uri = Uri.parse(route);
    state = uri
        .replace(
          queryParameters: {...uri.queryParameters, 'tap': '${++_tapCount}'},
        )
        .toString();
  }

  /// 값을 꺼내면서 비운다. 한 번 이동한 경로로 다시 이동하지 않게 한다.
  String? take() {
    final String? route = state;
    state = null;
    return route;
  }
}

final pendingNotificationRouteProvider =
    NotifierProvider<PendingNotificationRoute, String?>(
      PendingNotificationRoute.new,
    );
