import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 네트워크 계층의 예외를 화면에서 다루기 쉬운 형태로 감싼 도메인 예외.
/// 저장소(repository)가 [DioException]이나 파싱 오류를 이 타입으로 바꿔
/// 던지므로, 화면은 dio에 의존하지 않고도 실패 원인을 구분할 수 있다.
class ApiException implements Exception {
  /// HTTP 상태 코드. 서버 응답 자체를 받지 못했다면 null.
  final int? statusCode;

  /// 사용자에게 그대로 보여줄 수 있는 한국어 안내 문구.
  final String message;

  /// 서버가 응답 본문에 함께 내려주는 에러 코드(예: `NO_CANDIDATE_CERTIFICATE`).
  /// 화면이 상태 코드보다 더 구체적으로 분기해야 할 때 쓴다. 응답을 못
  /// 받았거나 코드 필드가 없으면 null.
  final String? code;

  const ApiException({this.statusCode, required this.message, this.code});

  bool get isUnauthorized => statusCode == 401;

  factory ApiException.fromDio(DioException exception) {
    final int? statusCode = exception.response?.statusCode;
    final dynamic responseData = exception.response?.data;
    final String? code = responseData is Map
        ? responseData['code'] as String?
        : null;
    // 서버가 함께 내려주는 문구. 400/401/403/404/409/5xx처럼 화면에
    // 맞춰 일부러 다른 말로 바꿔 쓰는 경우가 아니라면, 우리가 짐작한
    // 문구보다 서버가 실제 실패 사유를 담아 보내는 이 문구가 더 정확하다
    // (예: "온보딩을 먼저 완료해 주세요" 같은, 상태 코드만으로는 알 수
    // 없는 이유). 코드 하나하나를 다 알아서 분기하는 대신, 우리가
    // 명시적으로 다루지 않는 상태 코드에서는 이 문구를 그대로 쓴다.
    final String? serverMessage = responseData is Map
        ? responseData['message'] as String?
        : null;
    final String message = switch (exception.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => '서버 응답이 늦어지고 있어요. 잠시 후 다시 시도해주세요',
      DioExceptionType.connectionError => '네트워크 연결을 확인해주세요',
      DioExceptionType.badResponse => switch (statusCode) {
        400 => '요청 내용을 다시 확인해주세요',
        401 => '로그인이 필요해요',
        403 => '권한이 없어요',
        404 => '요청한 정보를 찾을 수 없어요',
        409 => '이미 처리된 요청이에요',
        final int code when code >= 500 =>
          '서버에 문제가 생겼어요. 잠시 후 다시 시도해주세요',
        _ => serverMessage ?? '요청을 처리하지 못했어요',
      },
      _ => '요청을 처리하지 못했어요',
    };
    return ApiException(statusCode: statusCode, message: message, code: code);
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
  } catch (error, stackTrace) {
    // 응답 형식이 예상과 달라 fromJson 등에서 실패한 경우. HTTP 상태는
    // 정상(2xx)인데 화면에는 에러로 보이는 경우 대부분 여기가 원인이므로,
    // 실제 예외를 콘솔에 남겨 원인을 바로 알 수 있게 한다.
    if (kDebugMode) {
      debugPrint('[API parse error] $error');
      debugPrintStack(stackTrace: stackTrace);
    }
    throw const ApiException(message: '응답을 처리하지 못했어요');
  }
}