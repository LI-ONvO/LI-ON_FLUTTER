import 'package:dio/dio.dart';

/// 네트워크 계층의 예외를 화면에서 다루기 쉬운 형태로 감싼 도메인 예외.
/// 저장소(repository)가 [DioException]이나 파싱 오류를 이 타입으로 바꿔
/// 던지므로, 화면은 dio에 의존하지 않고도 실패 원인을 구분할 수 있다.
class ApiException implements Exception {
  /// HTTP 상태 코드. 서버 응답 자체를 받지 못했다면 null.
  final int? statusCode;

  /// 사용자에게 그대로 보여줄 수 있는 한국어 안내 문구.
  final String message;

  const ApiException({this.statusCode, required this.message});

  bool get isUnauthorized => statusCode == 401;

  factory ApiException.fromDio(DioException exception) {
    final int? statusCode = exception.response?.statusCode;
    final String message = switch (exception.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => '서버 응답이 늦어지고 있어요. 잠시 후 다시 시도해주세요',
      DioExceptionType.connectionError => '네트워크 연결을 확인해주세요',
      DioExceptionType.badResponse => switch (statusCode) {
        400 => '요청 내용을 다시 확인해주세요',
        401 => '로그인이 필요해요',
        403 => '접근 권한이 없어요',
        404 => '요청한 정보를 찾을 수 없어요',
        409 => '이미 처리된 요청이에요',
        final int code when code >= 500 =>
          '서버에 문제가 생겼어요. 잠시 후 다시 시도해주세요',
        _ => '요청을 처리하지 못했어요',
      },
      _ => '요청을 처리하지 못했어요',
    };
    return ApiException(statusCode: statusCode, message: message);
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// API 호출을 감싸 [DioException]과 응답 파싱 오류를 [ApiException]으로
/// 통일해서 던진다. 저장소의 모든 HTTP 호출은 이 함수를 거친다.
Future<T> guardApiCall<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (exception) {
    throw ApiException.fromDio(exception);
  } on ApiException {
    rethrow;
  } catch (_) {
    // 응답 형식이 예상과 달라 fromJson 등에서 실패한 경우.
    throw const ApiException(message: '응답을 처리하지 못했어요');
  }
}