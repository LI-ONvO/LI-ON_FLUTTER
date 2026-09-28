import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/network/api_client.dart';
import 'package:li_on/core/network/api_exception.dart';
import 'package:li_on/core/notification/push_notification_service.dart';

abstract class DeviceTokenRepository {
  /// `POST /api/users/me/device-tokens` — 로그인 직후와 FCM `onTokenRefresh` 때 호출한다.
  Future<void> register(String token);

  /// `DELETE /api/users/me/device-tokens` — 로그아웃 시 이 기기의 토큰만 해제한다.
  /// 내 토큰이 아니거나 이미 없어도 서버가 204를 주므로 항상 성공으로 다룬다.
  Future<void> unregister(String token);
}

class HttpDeviceTokenRepository implements DeviceTokenRepository {
  HttpDeviceTokenRepository(this.apiClient);

  final ApiClient apiClient;

  @override
  Future<void> register(String token) {
    return guardApiCall(() async {
      await apiClient.dio.post(
        '/api/users/me/device-tokens',
        data: {'token': token},
      );
    });
  }

  @override
  Future<void> unregister(String token) {
    return guardApiCall(() async {
      await apiClient.dio.delete(
        '/api/users/me/device-tokens',
        data: {'token': token},
      );
    });
  }
}

final deviceTokenRepositoryProvider = Provider<DeviceTokenRepository>((ref) {
  return HttpDeviceTokenRepository(ref.watch(apiClientProvider));
});

/// 이 기기의 FCM 토큰을 서버에 등록한다. 로그인 직후에 부르며, 실패해도
/// 로그인 흐름은 막지 않도록 모든 오류를 삼킨다.
Future<void> registerCurrentDeviceToken(DeviceTokenRepository repository) {
  return _withCurrentDeviceToken(repository.register);
}

/// 이 기기의 FCM 토큰을 서버에서 해제한다. 로그아웃 때 accessToken을
/// 지우기 전에 불러야 하며, 실패해도 로그아웃은 막지 않도록 오류를 삼킨다.
Future<void> unregisterCurrentDeviceToken(DeviceTokenRepository repository) {
  return _withCurrentDeviceToken(repository.unregister);
}

Future<void> _withCurrentDeviceToken(
  Future<void> Function(String token) action,
) async {
  try {
    final String? fcmToken = await PushNotificationService.getToken();
    if (fcmToken != null) await action(fcmToken);
  } catch (_) {}
}
