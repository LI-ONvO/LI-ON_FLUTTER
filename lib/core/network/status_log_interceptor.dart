import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 디버그 콘솔에서 요청별 HTTP 상태 코드를 바로 확인할 수 있게 찍어준다.
/// 토큰·비밀번호·이메일 같은 민감한 값은 가려서 찍는다.
class StatusLogInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final RequestOptions options = response.requestOptions;
      debugPrint(
        '[HTTP ${response.statusCode}] ${options.method} ${options.path}\n'
        'body: ${maskSensitive(response.data)}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final RequestOptions options = err.requestOptions;
      debugPrint(
        '[HTTP ${err.response?.statusCode ?? '-'}] ${options.method} '
        '${options.path}?${maskSensitive(options.queryParameters)} '
        '(${err.type})\n'
        'body: ${maskSensitive(err.response?.data)}',
      );
    }
    handler.next(err);
  }
}

const String _mask = '***';

/// 키 이름에 이 단어가 들어가면 값을 가린다. (대소문자 무시)
const List<String> _sensitiveKeywords = <String>['token', 'password', 'email'];

bool _isSensitiveKey(Object? key) {
  final String lower = key.toString().toLowerCase();
  return _sensitiveKeywords.any(lower.contains);
}

/// Map/List를 따라 내려가며 민감한 키의 값을 [_mask]로 바꾼 사본을 돌려준다.
@visibleForTesting
Object? maskSensitive(Object? data) {
  if (data is Map) {
    return data.map(
      (Object? key, Object? value) =>
          MapEntry(key, _isSensitiveKey(key) ? _mask : maskSensitive(value)),
    );
  }
  if (data is List) return data.map(maskSensitive).toList();
  return data;
}
