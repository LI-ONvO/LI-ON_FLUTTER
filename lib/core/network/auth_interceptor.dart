import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:li_on/core/network/token_storage.dart';
import 'package:li_on/pages/auth/model/token_refresh_result.dart';

/// 모든 요청에 액세스 토큰을 붙이고, 401 응답을 받으면 리프레시 토큰으로
/// 액세스 토큰을 갱신한 뒤 실패한 요청을 한 번 재시도한다.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(
    this._tokenStorage,
    this._refreshDio, {
    required this.onSessionExpired,
  });

  final TokenStorage _tokenStorage;

  /// 토큰 갱신 전용 Dio. 이 인터셉터가 붙어 있지 않아, 갱신 요청이 다시
  /// 401을 받아도 무한 재시도에 빠지지 않는다.
  final Dio _refreshDio;
  final VoidCallback onSessionExpired;

  /// 여러 요청이 동시에 401을 받아도 갱신은 한 번만 하도록 공유한다.
  Future<String?>? _ongoingRefresh;

  /// 재시도한 요청이 또 401을 받았을 때 다시 갱신을 시도하지 않기 위한 표식.
  static const String _retriedKey = 'authInterceptorRetried';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String? token = await _tokenStorage.readAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final RequestOptions request = err.requestOptions;
    final bool isUnauthorized = err.response?.statusCode == 401;
    final bool alreadyRetried = request.extra[_retriedKey] == true;
    if (!isUnauthorized || alreadyRetried) {
      handler.next(err);
      return;
    }

    final String? newAccessToken = await _refreshAccessToken();
    if (newAccessToken == null) {
      // 갱신에 실패했으므로 남은 토큰을 지우고 원래의 401을 그대로 흘려
      // 보낸다. 로그인 화면으로 보내는 처리는 화면 쪽 몫이다.
      await _tokenStorage.clear();
      onSessionExpired();
      handler.next(err);
      return;
    }

    try {
      request.headers['Authorization'] = 'Bearer $newAccessToken';
      request.extra[_retriedKey] = true;
      final Response<dynamic> response = await _refreshDio.fetch(request);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  /// 리프레시 토큰으로 새 액세스 토큰을 받아 저장하고 돌려준다.
  /// 이미 진행 중인 갱신이 있으면 그 결과를 함께 기다린다.
  Future<String?> _refreshAccessToken() {
    return _ongoingRefresh ??= _doRefresh().whenComplete(() {
      _ongoingRefresh = null;
    });
  }

  Future<String?> _doRefresh() async {
    final String? refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) return null;

    try {
      // 서버는 리프레시 토큰을 Authorization 헤더가 아니라 요청 바디의
      // `refreshToken` 필드로 받는다(직접 호출해 확인: 헤더로 보내면
      // "refreshToken must be a jwt string, refreshToken should not be
      // empty"로 422가 남).
      final Response<dynamic> response = await _refreshDio.post(
        '/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final TokenRefreshResult result = TokenRefreshResult.fromJson(
        response.data as Map<String, dynamic>,
      );
      await _tokenStorage.saveTokens(
        accessToken: result.accessToken,
        // 서버가 리프레시 토큰을 회전시키면 새 값으로 교체하고, 안 주면
        // 기존 값을 유지한다.
        refreshToken: result.refreshToken ?? refreshToken,
      );
      return result.accessToken;
    } catch (_) {
      return null;
    }
  }
}
