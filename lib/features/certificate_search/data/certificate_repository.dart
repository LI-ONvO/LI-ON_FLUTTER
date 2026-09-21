import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/network/api_client.dart';
import 'package:li_on/core/network/api_exception.dart';
import 'package:li_on/features/certificate_search/data/certificate.dart';
import 'package:li_on/features/certificate_search/data/certificate_detail.dart';
import 'package:li_on/features/certificate_search/data/certificate_search_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 자격증 목록을 가져오는 방법을 추상화한다.
abstract class CertificateRepository {
  /// 자격증 목록. [keyword]·[fieldId]를 주면 서버에서 필터링해 준다.
  Future<List<Certificate>> fetchCertificates({String? keyword, int? fieldId});
  Future<CertificateDetail?> fetchCertificateDetail(String id);
}

final certificateRepositoryProvider = Provider<CertificateRepository>((ref) {
  return HttpCertificateRepository(ref.watch(apiClientProvider));
});

/// `GET /api/certificates`·`GET /api/certificates/{id}`를 쓰는 실제 구현체.
class HttpCertificateRepository implements CertificateRepository {
  HttpCertificateRepository(this.apiClient);

  final ApiClient apiClient;

  /// 화면이 페이지네이션 없이 전체를 필터링하므로 마지막 페이지까지
  /// 모두 모아서 돌려준다. 서버에 자격증이 3,600여 개 있어 한 번의
  /// 요청만으로는 일부만 받아오게 된다.
  ///
  /// size를 100 넘게 요청하면 서버가 422로 거부해(페이지 크기 상한이
  /// 있는 것으로 보임), 이전에 확인됐던 100을 그대로 쓰고 페이지 수를
  /// 늘려서 커버한다.
  static const int _pageSize = 100;

  /// 서버가 계속 꽉 찬 페이지를 주는 이상 상황에서도 무한히 요청하지
  /// 않도록 두는 안전장치. 100 * 100 = 10,000개까지 커버한다.
  static const int _maxPages = 100;

  /// 앱을 새로 켤 때마다 3,600여 개를 매번 다시 받아오지 않도록 기기에
  /// 저장해 재사용한다. [Certificate]의 JSON 형태가 바뀌면 옛 캐시를
  /// 못 읽고 죽는 대신 그냥 무시하고 새로 받아오도록, 모델을 바꿀 때는
  /// 이 키의 버전(`v1`)을 올린다.
  static const String _cacheKey = 'certificates_cache_v2';
  static const String _cacheSavedAtKey = 'certificates_cache_saved_at_v2';

  /// 국가자격 목록은 자주 바뀌지 않으니, 이 기간 동안은 캐시를 그대로 쓴다.
  static const Duration _cacheTtl = Duration(days: 1);

  @override
  Future<List<Certificate>> fetchCertificates({
    String? keyword,
    int? fieldId,
  }) {
    return guardApiCall(() async {
      // 캐시는 "필터 없이 전체 목록"을 부르는 호출에만 쓴다. 화면이
      // 서버 필터링 없이 전체를 받아 클라이언트에서 걸러내는 방식이라,
      // 지금은 이 경우만 실제로 쓰인다.
      final bool isFullList =
          (keyword == null || keyword.isEmpty) && fieldId == null;

      if (isFullList) {
        final List<Certificate>? cached = await _readCache();
        if (cached != null) return cached;
      }

      final List<Certificate> all = [];
      for (int page = 0; page < _maxPages; page++) {
        final response = await apiClient.dio.get(
          '/api/certificates',
          queryParameters: {
            if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
            'fieldId': ?fieldId,
            'page': page,
            'size': _pageSize,
          },
        );
        final List<Certificate> pageContent = CertificateSearchResult.fromJson(
          response.data,
        ).content;
        all.addAll(pageContent);
        // 꽉 채워지지 않은 페이지가 왔다는 건 마지막 페이지라는 뜻이다.
        // totalPages 등 메타 필드는 서버마다 형태가 달라 신뢰하지 않는다.
        if (pageContent.length < _pageSize) break;
      }

      if (isFullList) await _writeCache(all);
      return all;
    });
  }

  Future<List<Certificate>?> _readCache() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? savedAtRaw = prefs.getString(_cacheSavedAtKey);
      final String? raw = prefs.getString(_cacheKey);
      if (raw == null || savedAtRaw == null) return null;

      final DateTime? savedAt = DateTime.tryParse(savedAtRaw);
      if (savedAt == null || DateTime.now().difference(savedAt) > _cacheTtl) {
        return null;
      }

      return (jsonDecode(raw) as List<dynamic>)
          .map((item) => Certificate.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // 캐시가 손상됐어도 서버에서 새로 받아오면 되니 실패로 취급하지 않는다.
      return null;
    }
  }

  Future<void> _writeCache(List<Certificate> certificates) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _cacheKey,
        jsonEncode(certificates.map((c) => c.toJson()).toList()),
      );
      await prefs.setString(
        _cacheSavedAtKey,
        DateTime.now().toIso8601String(),
      );
    } catch (_) {
      // 캐시 저장 실패는 무시한다 — 다음에 다시 네트워크로 받아오면 된다.
    }
  }

  @override
  Future<CertificateDetail?> fetchCertificateDetail(String id) {
    return guardApiCall(() async {
      try {
        final response = await apiClient.dio.get('/api/certificates/$id');
        return CertificateDetail.fromJson(response.data);
      } on DioException catch (exception) {
        // 존재하지 않는 자격증은 오류가 아니라 null로 알려, 화면이
        // "찾을 수 없음" 상태를 그리게 한다.
        if (exception.response?.statusCode == 404) return null;
        rethrow;
      }
    });
  }
}

final certificatesProvider = FutureProvider<List<Certificate>>((ref) {
  return ref.watch(certificateRepositoryProvider).fetchCertificates();
});

/// 자격증 상세 정보.
/// [id]는 [Certificate.id]와 매칭되는 키다.
final certificateDetailProvider = FutureProvider.autoDispose
    .family<CertificateDetail?, String>((ref, id) {
      return ref
          .watch(certificateRepositoryProvider)
          .fetchCertificateDetail(id);
    });
