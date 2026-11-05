import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:li_on/core/network/api_client.dart';
import 'package:li_on/core/network/api_exception.dart';
import 'package:li_on/features/roadmap/data/roadmap_repository.dart';

void main() {
  /// 네트워크 대신 [respond]가 응답하는 저장소를 만든다.
  HttpRoadmapRepository makeRepository(
    void Function(RequestOptions options, RequestInterceptorHandler handler)
    respond,
  ) {
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://test'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: respond));
    return HttpRoadmapRepository(ApiClient(dio));
  }

  test('자격증 선택은 세션의 certificates로 jmCd를 POST한다', () async {
    late RequestOptions request;
    final HttpRoadmapRepository repository = makeRepository((options, handler) {
      request = options;
      handler.resolve(Response(requestOptions: options, statusCode: 204));
    });

    await repository.selectSessionCertificate(sessionId: 7, jmCd: 'C177');

    expect(request.method, 'POST');
    expect(request.path, '/api/chat/sessions/7/certificates');
    expect(request.data, {'jmCd': 'C177'});
  });

  test('이미 자격증이 선택된 세션이면 422의 에러 코드를 전달한다', () async {
    final HttpRoadmapRepository repository = makeRepository((options, handler) {
      handler.reject(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 422,
            data: {'code': 'CERTIFICATE_ALREADY_EXISTS'},
          ),
        ),
      );
    });

    await expectLater(
      repository.selectSessionCertificate(sessionId: 7, jmCd: 'C177'),
      throwsA(
        isA<ApiException>().having(
          (error) => error.code,
          'code',
          'CERTIFICATE_ALREADY_EXISTS',
        ),
      ),
    );
  });
}
