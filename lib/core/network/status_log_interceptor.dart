import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 디버그 콘솔에서 요청별 HTTP 상태 코드를 바로 확인할 수 있게 찍어준다.
class StatusLogInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final RequestOptions options = response.requestOptions;
      debugPrint(
        '[HTTP ${response.statusCode}] ${options.method} ${options.path}\n'
        'body: ${response.data}',
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
        '${options.path}?${options.queryParameters} (${err.type})\n'
        'body: ${err.response?.data}',
      );
    }
    handler.next(err);
  }
}
