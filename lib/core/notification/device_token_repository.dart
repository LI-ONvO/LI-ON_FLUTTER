import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/network/api_client.dart';
import 'package:li_on/core/network/api_exception.dart';

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
