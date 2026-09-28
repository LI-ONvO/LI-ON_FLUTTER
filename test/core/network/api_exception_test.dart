import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/core/network/api_exception.dart';

DioException _badResponse(int statusCode, Object? data) {
  final RequestOptions options = RequestOptions(path: '/test');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: options,
      statusCode: statusCode,
      data: data,
    ),
  );
}

void main() {
  test('응답의 code·message가 문자열이면 그대로 쓴다', () {
    final ApiException exception = ApiException.fromDio(
      _badResponse(422, {'code': 'NO_CANDIDATE', 'message': '후보가 없어요'}),
    );

    expect(exception.code, 'NO_CANDIDATE');
    expect(exception.message, '후보가 없어요');
  });

  test('응답의 code·message가 문자열이 아니어도 예외 없이 기본 문구를 쓴다', () {
    final ApiException exception = ApiException.fromDio(
      _badResponse(422, {
        'code': 1001,
        'message': {'detail': 'x'},
      }),
    );

    expect(exception.statusCode, 422);
    expect(exception.code, isNull);
    expect(exception.message, '요청을 처리하지 못했어요');
  });
}
