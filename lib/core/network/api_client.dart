import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/network/auth_interceptor.dart';
import 'package:li_on/core/network/token_storage.dart';
import 'package:li_on/pages/auth/provider/auth_session.dart';

/// API 서버 주소. 빌드 시 `--dart-define=API_BASE_URL=https://...`로
/// 주입한다. 지정하지 않으면 로컬 개발 서버를 바라본다.
const String _defaultBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  factory ApiClient.create({
    required String baseUrl,
    required TokenStorage token,
    required VoidCallback onSessionExpired,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        receiveTimeout: Duration(seconds: 10),
        connectTimeout: Duration(seconds: 10),
      ),
    );
    // 토큰 갱신 요청은 인터셉터가 없는 별도 Dio로 보내, 갱신 요청이 다시
    // 401을 받아도 무한 재시도에 빠지지 않게 한다.
    final Dio refreshDio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        receiveTimeout: Duration(seconds: 10),
        connectTimeout: Duration(seconds: 10),
      ),
    );
    dio.interceptors.add(
      AuthInterceptor(token, refreshDio, onSessionExpired: onSessionExpired),
    );
    return ApiClient(dio);
  }

  Dio get dio => _dio;
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient.create(
    baseUrl: _defaultBaseUrl,
    token: ref.watch(tokenStorageProvider),
    onSessionExpired: ref.read(authSessionProvider).signOut,
  );
});
